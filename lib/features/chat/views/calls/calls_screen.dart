import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../controllers/call_controller.dart';
import '../../models/call_model.dart';

class CallsScreen extends StatelessWidget {
  const CallsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CallController controller = Get.put(CallController());
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.headerDarkGreen,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: AppColors.headerDarkGreen,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.search, color: AppColors.textWhite),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: Text(
                      localizations.calls,
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_call, color: AppColors.textWhite),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            
            // Calls List
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
                      child: Text(
                        localizations.recent,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    
                    Expanded(
                      child: Obx(() => ListView.builder(
                        padding: const EdgeInsets.only(top: 8),
                        itemCount: controller.calls.length,
                        itemBuilder: (context, index) {
                          final call = controller.calls[index];
                          return _buildCallItem(context, call, controller);
                        },
                      )),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallItem(BuildContext context, CallModel call, CallController controller) {
    Color callIconColor;
    IconData callIcon;

    switch (call.type) {
      case CallType.incoming:
        callIconColor = AppColors.callIncoming;
        callIcon = Icons.call_received_rounded;
        break;
      case CallType.outgoing:
        callIconColor = AppColors.callOutgoing;
        callIcon = Icons.call_made_rounded;
        break;
      case CallType.missed:
        callIconColor = AppColors.callMissed;
        callIcon = Icons.call_missed_rounded;
        break;
    }

    return InkWell(
      onTap: () {
        // Handle call tap
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Profile Picture
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: call.isGroup 
                    ? AppColors.primaryTeal 
                    : AppColors.headerDarkGreen,
              ),
              child: call.isGroup
                  ? const Icon(
                      Icons.group,
                      color: AppColors.textWhite,
                      size: 28,
                    )
                  : const Icon(
                      Icons.person,
                      color: AppColors.textWhite,
                      size: 28,
                    ),
            ),
            const SizedBox(width: 16),
            
            // Call Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    call.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        callIcon,
                        size: 16,
                        color: callIconColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        controller.formatCallTime(call.callTime),
                        style: TextStyle(
                          fontSize: 14,
                          color: call.type == CallType.missed
                              ? AppColors.callMissed
                              : AppColors.textLightGray,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Action Buttons
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.phone,
                    color: AppColors.textLightGray,
                  ),
                  onPressed: () {
                    // Make voice call
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.videocam,
                    color: AppColors.textLightGray,
                  ),
                  onPressed: () {
                    // Make video call
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

