import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spamdetection/features/chat/controllers/call_controller.dart';

class CallScreen extends StatefulWidget {
  final String callId;
  final String channelId;
  final bool isVideo;
  final bool isCaller;

  const CallScreen({
    super.key,
    required this.callId,
    required this.channelId,
    required this.isVideo,
    this.isCaller = true, // true = Caller, false = Receiver
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final CallController callController = Get.find();
  String callStatus = 'ringing';
  StreamSubscription<DocumentSnapshot>? _callSub;

  @override
  void initState() {
    super.initState();

    // Listen to call document for status changes
    _callSub = FirebaseFirestore.instance
        .collection('calls')
        .doc(widget.callId)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) return;
      final data = snapshot.data()!;
      setState(() {
        callStatus = data['status'] ?? 'ringing';
      });

      // Auto pop screen if call ends or rejected
      if (callStatus == 'ended' || callStatus == 'rejected') {
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _callSub?.cancel();
    super.dispose();
  }

  void _acceptCall() async {
    await callController.acceptCall(widget.callId, widget.channelId);
    // TODO: Join Agora channel here
  }

  void _rejectCall() async {
    await callController.endCall(widget.callId); // Always use endCall to update Firestore
    Navigator.pop(context);
  }

  void _endCall() async {
    await callController.endCall(widget.callId); // Updates Firestore
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Call ID: ${widget.callId}', style: const TextStyle(color: Colors.white)),
            Text('Channel ID: ${widget.channelId}', style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 20),
            Text('Status: $callStatus', style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 40),

            // Receiver buttons
            if (!widget.isCaller && callStatus == 'ringing') ...[
              ElevatedButton(
                onPressed: _acceptCall,
                child: const Text('Accept Call'),
              ),
              ElevatedButton(
                onPressed: _rejectCall,
                child: const Text('Reject Call'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],

            // Caller buttons
            if (widget.isCaller && callStatus == 'ringing') ...[
              ElevatedButton(
                onPressed: _endCall,
                child: const Text('Cancel Call'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],

            // End call button after accepted
            if (callStatus == 'accepted') ...[
              ElevatedButton(
                onPressed: _endCall,
                child: const Text('End Call'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
