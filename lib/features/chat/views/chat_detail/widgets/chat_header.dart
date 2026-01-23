import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:spamdetection/core/constants/app_colors.dart';
import 'package:spamdetection/core/localization/app_localizations.dart';
import 'package:spamdetection/core/routes/app_routes.dart';
import 'package:spamdetection/features/chat/models/chat_model.dart';

class ChatHeader extends StatelessWidget {
  final ChatModel chat;

  const ChatHeader({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.borderDark
                : AppColors.borderGray,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // This matches the mobile gesture behavior
              Get.offAllNamed(AppRoutes.mainNavigation);
            },
          ),
          _buildProfileStack(context),
          const SizedBox(width: 12),
          _buildNameAndStatus(context, localizations),
          IconButton(icon: const Icon(Icons.phone), onPressed: () {}),
          IconButton(icon: const Icon(Icons.videocam), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildProfileStack(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 22.5,
          backgroundColor: Colors.yellow[700]?.withAlpha(50),
          child:  Icon(Icons.person, color: Colors.yellow[700], size: 28),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green,
              border: Border.all(
                color: Theme.of(context).scaffoldBackgroundColor,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNameAndStatus(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            chat.name,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Text(
            localizations.activeNow,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textLightGray,
            ),
          ),
        ],
      ),
    );
  }
}
