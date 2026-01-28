import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:spamdetection/features/chat/views/calls/Call_UI.dart';

class IncomingCallScreen extends StatelessWidget {
  final String callId;
  final String channelId;
  final bool isVideo;
  final String callerId;

  const IncomingCallScreen({
    super.key,
    required this.callId,
    required this.channelId,
    required this.isVideo,
    required this.callerId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Incoming Call from $callerId', style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Accept call -> navigate to CallScreen
                    FirebaseFirestore.instance.collection('calls').doc(callId).update({
                      'status': 'ongoing',
                    });
                    Get.to(
                      CallScreen(
                        callId: callId,
                        channelId: channelId,
                        isVideo: isVideo,
                      ),
                    );
                  },
                  child: const Text('Accept'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    // Decline call -> update status
                    FirebaseFirestore.instance.collection('calls').doc(callId).update({
                      'status': 'declined',
                    });
                    Get.back();
                  },
                  child: const Text('Decline'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
