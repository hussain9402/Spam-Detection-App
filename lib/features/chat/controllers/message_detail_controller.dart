import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../models/message_model.dart';
import '../models/chat_model.dart';
import '../../authentication/controllers/auth_controller.dart';

class MessageDetailController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final AuthController authController = Get.find<AuthController>();
  final AudioRecorder _recorder = AudioRecorder();
  final _box = GetStorage();
  
  final Rx<ChatModel?> chat = Rx<ChatModel?>(null);
  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxBool isActive = true.obs; 
  final RxString messageText = ''.obs;

  // Recording states
  final RxBool isRecording = false.obs;
  final RxString recordingPath = ''.obs;
  final RxInt recordingDuration = 0.obs;
  final RxDouble amplitude = (-160.0).obs; // Added for amplitude tracking
  StreamSubscription<Amplitude>? _amplitudeSubscription;
  DateTime? _recordingStartTime;
  Timer? _durationTimer;

  @override
  void onClose() {
    _recorder.dispose();
    super.onClose();
  }

  void initializeWithChat(ChatModel chatModel) {
    chat.value = chatModel;
    _loadLocalFailedMessages();
    listenToMessages();
  }

  // --- LOCAL PERSISTENCE FOR FAILED MESSAGES ---

  String get _storageKey => 'failed_messages_${chat.value?.id}';

  void _saveLocalFailedMessages() {
    final failed = messages.where((m) => m.status == MessageStatus.failed).map((m) => {
      'id': m.id,
      'content': m.content,
      'type': m.type.index,
      'timestamp': m.timestamp.toIso8601String(),
      'localPath': m.localPath,
      'voiceDuration': m.voiceDuration, // Save duration for voice messages
    }).toList();
    _box.write(_storageKey, jsonEncode(failed));
  }

  void _loadLocalFailedMessages() {
    final stored = _box.read(_storageKey);
    if (stored != null) {
      final List<dynamic> decoded = jsonDecode(stored);
      final myPhone = authController.currentUser.value?.phoneNumber ?? '';
      
      for (var data in decoded) {
        final msg = MessageModel(
          id: data['id'],
          senderId: myPhone,
          senderName: 'You',
          content: data['content'],
          type: MessageType.values[data['type']],
          timestamp: DateTime.parse(data['timestamp']),
          isSent: true,
          status: MessageStatus.failed,
          localPath: data['localPath'],
          voiceDuration: data['voiceDuration'], // Restore duration for voice messages
        );
        if (!messages.any((m) => m.id == msg.id)) {
          messages.add(msg);
        }
      }
    }
  }

  // Real-time listener for Firestore messages
  void listenToMessages() {
    if (chat.value == null) return;

    _firestore
        .collection('chats')
        .doc(chat.value!.id)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots(includeMetadataChanges: true)
        .listen((snapshot) {
      final docs = snapshot.docs;
      
      final firestoreMessages = docs.map((doc) {
        final data = doc.data();
        final String senderNumber = data['senderNumber'] ?? '';
        final String myNumber = authController.currentUser.value?.phoneNumber ?? '';

        DateTime msgTime;
        if (data['timestamp'] == null) {
          msgTime = DateTime.now();
        } else {
          msgTime = (data['timestamp'] as Timestamp).toDate();
        }

        return MessageModel(
          id: doc.id,
          senderId: senderNumber,
          senderName: senderNumber == myNumber ? 'You' : (chat.value?.name ?? 'Other'),
          content: data['content'] ?? '',
          type: data['type'] == 'voice' ? MessageType.voice : (data['type'] == 'image' ? MessageType.image : MessageType.text),
          timestamp: msgTime,
          isSent: senderNumber == myNumber,
          voiceDuration: data['duration'] ?? 0,
          status: MessageStatus.sent,
        );
      }).toList();

      // Merge firestore messages with local failed/sending ones
      final localOnly = messages.where((m) => m.status != MessageStatus.sent).toList();
      
      messages.assignAll(firestoreMessages);
      
      for (var local in localOnly) {
        if (!messages.any((m) => m.id == local.id)) {
          messages.add(local);
        }
      }
      
      // Keep sorted by timestamp
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    });
  }

  // --- Voice Recording Methods ---

  Future<void> startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        const config = RecordConfig();
        
        await _recorder.start(config, path: path);
        isRecording.value = true;
        recordingPath.value = path;
        recordingDuration.value = 0;
        amplitude.value = -160.0; // Reset amplitude
        _recordingStartTime = DateTime.now();
        
        // Start timer to track duration
        _durationTimer?.cancel();
        _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (_recordingStartTime != null) {
            recordingDuration.value = DateTime.now().difference(_recordingStartTime!).inSeconds;
          }
        });
        
        // Start listening to amplitude and store subscription
        _amplitudeSubscription?.cancel();
        _amplitudeSubscription = _recorder.onAmplitudeChanged(const Duration(milliseconds: 50)).listen((amp) {
          amplitude.value = amp.current;
        });
      }
    } catch (e) {
      print("Error starting recording: $e");
    }
  }

  Future<void> stopRecording() async {
    try {
      _amplitudeSubscription?.cancel();
      _amplitudeSubscription = null;
      _durationTimer?.cancel();
      _durationTimer = null;
      amplitude.value = -160.0; // Reset amplitude
      
      final path = await _recorder.stop();
      isRecording.value = false;
      
      // Calculate final duration - use the higher of timer value or calculated difference
      int finalDuration = 0;
      if (_recordingStartTime != null) {
        final calculatedDuration = DateTime.now().difference(_recordingStartTime!).inSeconds;
        finalDuration = calculatedDuration > recordingDuration.value 
            ? calculatedDuration 
            : recordingDuration.value;
        if (finalDuration < 1) finalDuration = 1; // Minimum 1 second
        recordingDuration.value = finalDuration;
      } else if (recordingDuration.value > 0) {
        finalDuration = recordingDuration.value;
      } else {
        finalDuration = 1; // Default to 1 second if nothing was tracked
      }
      
      print("DEBUG: Recording stopped. Duration: $finalDuration seconds, Path: $path");
      print("DEBUG: Timer value: ${recordingDuration.value}, Start time: $_recordingStartTime");
      
      if (path != null && finalDuration > 0) {
        await sendVoiceMessage(path, finalDuration);
      } else {
        print("DEBUG: Cannot send voice message - path: $path, duration: $finalDuration");
        Get.snackbar("Error", "Recording too short or file not found");
      }
      
      _recordingStartTime = null;
    } catch (e) {
      print("Error stopping recording: $e");
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> sendVoiceMessage(String path, int duration) async {
    if (chat.value == null) return;

    final String chatId = chat.value!.id;
    final String myPhone = authController.currentUser.value?.phoneNumber ?? '';
    final String otherPhone = chat.value!.phoneNumber ?? '';
    final File file = File(path);
    final String tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';

    // 1. Add to local list immediately with current timestamp (so it appears at the end)
    final localMsg = MessageModel(
      id: tempId,
      senderId: myPhone,
      senderName: 'You',
      content: path, // Local path for now
      type: MessageType.voice,
      timestamp: DateTime.now(), // Current timestamp ensures it's the newest
      isSent: true,
      status: MessageStatus.sending,
      localPath: path,
      voiceDuration: duration,
    );
    messages.add(localMsg);
    // Sort to ensure newest messages are at the end
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // 2. Update chat document immediately with duration (so it shows in chat list even if upload fails)
    final durationText = _formatDuration(duration);
    final lastMessageText = '🎤 Voice message $durationText';
    print("DEBUG: Updating chat with lastMessage: $lastMessageText, duration: $duration");
    
    try {
      // Update chat document first so duration shows immediately
      await _firestore.collection('chats').doc(chatId).set({
        'participants': [myPhone, otherPhone],
        'lastMessage': lastMessageText,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'otherUserName': chat.value!.name,
      }, SetOptions(merge: true));

      // 3. Upload to Firebase Storage
      final String fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final Reference ref = _storage.ref().child('chats/$chatId/voice/$fileName');
      final UploadTask uploadTask = ref.putFile(file);
      
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // 4. Send the message to Firestore
      await _firestore.collection('chats').doc(chatId).collection('messages').add({
        'senderNumber': myPhone,
        'content': downloadUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'voice',
        'duration': duration,
      });

      // Remove local temp message (Firestore listener will bring the real one)
      messages.removeWhere((m) => m.id == tempId);

    } catch (e) {
      print("Error sending voice message: $e");
      // Update local message to failed, but keep the chat document updated with duration
      int index = messages.indexWhere((m) => m.id == tempId);
      if (index != -1) {
        messages[index] = messages[index].copyWith(status: MessageStatus.failed);
        _saveLocalFailedMessages(); // Save to local storage
      }
      // Chat document already has the duration, so it will show in the list
    }
  }

  Future<void> resendMessage(MessageModel message) async {
    print("DEBUG: Resending message with ID: ${message.id}, type: ${message.type}, path: ${message.localPath}");
    
    // Find the exact message to resend by ID (to avoid stale references)
    final messageIndex = messages.indexWhere((m) => m.id == message.id);
    if (messageIndex == -1) {
      print("DEBUG: Message not found in list, cannot resend");
      return;
    }
    
    final messageToResend = messages[messageIndex];
    
    if (messageToResend.localPath == null && messageToResend.type == MessageType.voice) {
      print("DEBUG: Voice message has no local path, cannot resend");
      return;
    }
    
    // Store the values before removing
    final localPath = messageToResend.localPath;
    int duration = messageToResend.voiceDuration ?? 0;
    final content = messageToResend.content;
    final messageType = messageToResend.type;
    
    // If duration is 0, try to get it from the saved data or default to 1
    if (duration == 0 && messageType == MessageType.voice) {
      print("DEBUG: Duration is 0, checking if we can recover it");
      // Try to get duration from the message content or use a default
      // For now, we'll use 1 second as minimum, but ideally we'd calculate from file
      duration = 1;
    }
    
    print("DEBUG: Resending - duration: $duration, localPath: $localPath, type: $messageType");
    
    // Remove the failed one and try again
    messages.removeAt(messageIndex);
    _saveLocalFailedMessages(); // Update local storage
    
    if (messageType == MessageType.voice && localPath != null) {
      print("DEBUG: Resending voice message with duration: $duration, path: $localPath");
      await sendVoiceMessage(localPath, duration);
    } else if (messageType == MessageType.text) {
      print("DEBUG: Resending text message: $content");
      messageText.value = content;
      await sendMessage();
    }
  }

  Future<void> sendMessage() async {
    if (messageText.value.trim().isEmpty || chat.value == null) return;

    final String text = messageText.value.trim();
    final String chatId = chat.value!.id;
    final String myPhone = authController.currentUser.value?.phoneNumber ?? '';
    final String otherPhone = chat.value!.phoneNumber ?? '';
    final String tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';

    // Add local sending message with current timestamp (so it appears at the end)
    final localMsg = MessageModel(
      id: tempId,
      senderId: myPhone,
      senderName: 'You',
      content: text,
      type: MessageType.text,
      timestamp: DateTime.now(), // Current timestamp ensures it's the newest
      isSent: true,
      status: MessageStatus.sending,
    );
    messages.add(localMsg);
    // Sort to ensure newest messages are at the end
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    messageText.value = '';

    try {
      await _firestore.collection('chats').doc(chatId).collection('messages').add({
        'senderNumber': myPhone,
        'content': text,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'text',
      });

      await _firestore.collection('chats').doc(chatId).set({
        'participants': [myPhone, otherPhone],
        'lastMessage': text,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'otherUserName': chat.value!.name,
      }, SetOptions(merge: true));

      messages.removeWhere((m) => m.id == tempId);
      _saveLocalFailedMessages(); // Cleanup if it was a resend
    } catch (e) {
      print("Error sending message: $e");
      int index = messages.indexWhere((m) => m.id == tempId);
      if (index != -1) {
        messages[index] = messages[index].copyWith(status: MessageStatus.failed);
        _saveLocalFailedMessages(); // Save to local storage
      }
    }
  }

  String formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}