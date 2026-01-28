import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:spamdetection/features/authentication/controllers/auth_controller.dart';
import 'package:spamdetection/features/chat/views/calls/IncomingCallScreen.dart';
import '../models/call_model.dart';

class CallController extends GetxController {
  final RxList<CallModel> calls = <CallModel>[].obs;

  // Firestore subscription for incoming calls
  StreamSubscription<QuerySnapshot>? incomingCallSub;

  // AuthController to get current user
  final AuthController authController = Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
    listenForIncomingCalls();
  }

  @override
  void onClose() {
    incomingCallSub?.cancel();
    super.onClose();
  }

  // ===========================
  // Firestore Call Signaling
  // ===========================

  /// Create a new call document (Caller)
  Future<String?> createCall({
    required String receiverId,
    required bool isVideo,
  }) async {
    final String callerId = authController.currentUser.value?.phoneNumber ?? '';
    if (callerId.isEmpty) return null;

    final callId = DateTime.now().millisecondsSinceEpoch.toString();
    final channelId = 'call_$callId';

    await FirebaseFirestore.instance.collection('calls').doc(callId).set({
      'callId': callId,
      'channelId': channelId,
      'callerId': callerId,
      'receiverId': receiverId,
      'isVideo': isVideo,
      'status': 'ringing', // ringing | accepted | rejected | ended
      'timestamp': FieldValue.serverTimestamp(),
    });

    print("Call created with ID: $callId to $receiverId");

    // Listen for status changes (accepted/rejected/ended)
    _listenToCallStatus(callId, onUpdate: (status) {
      if (status == 'accepted') {
        print("Receiver accepted the call");
        // TODO: Join Agora channel here
      } else if (status == 'rejected' || status == 'ended') {
        print("Call was rejected or ended");
        // TODO: Show call ended UI
      }
    });

    return callId;
  }

  /// Listen for incoming calls for the current user (Receiver)
  void listenForIncomingCalls() {
    final String currentUserId = authController.currentUser.value?.phoneNumber ?? '';
    if (currentUserId.isEmpty) return;

    incomingCallSub = FirebaseFirestore.instance
        .collection('calls')
        .where('receiverId', isEqualTo: currentUserId)
        .where('status', isEqualTo: 'ringing')
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final callId = doc.id; // ALWAYS use doc.id
        final channelId = data['channelId'] ?? '';
        final callerId = data['callerId'] ?? '';
        final isVideo = data['isVideo'] ?? false;

        print("Incoming call from $callerId, channel: $channelId");

        // Navigate to IncomingCallScreen
        Get.to(() => IncomingCallScreen(
              callId: callId,
              channelId: channelId,
              callerId: callerId,
              isVideo: isVideo,
            ));
      }
    });
  }

  /// Accept an incoming call (Receiver)
  Future<void> acceptCall(String callId, String channelId) async {
    final docRef = FirebaseFirestore.instance.collection('calls').doc(callId);
    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      print("Error: Call document not found!");
      return;
    }

    await docRef.update({'status': 'accepted'});
    print("Call accepted: $callId");

    // TODO: Join Agora channel with channelId
  }

  /// Reject an incoming call (Receiver)
  Future<void> rejectCall(String callId) async {
    final docRef = FirebaseFirestore.instance.collection('calls').doc(callId);
    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      print("Error: Call document not found!");
      return;
    }

    await docRef.update({'status': 'rejected'});
    print("Call rejected: $callId");
  }

  /// End the call (both Caller and Receiver)
  Future<void> endCall(String callId) async {
    final docRef = FirebaseFirestore.instance.collection('calls').doc(callId);
    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      print("Error: Call document not found!");
      return;
    }

    await docRef.update({'status': 'ended'});
    print("Call ended: $callId");

    // TODO: Leave Agora channel if in call
  }

  // ===========================
  // Listen for specific call status
  // ===========================
  void _listenToCallStatus(
    String callId, {
    required Function(String status) onUpdate,
  }) {
    FirebaseFirestore.instance.collection('calls').doc(callId).snapshots().listen((doc) {
      final data = doc.data();
      if (data == null) return;

      final status = data['status'] ?? '';
      onUpdate(status);
    });
  }
}
