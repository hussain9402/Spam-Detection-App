import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spamdetection/core/constants/app_colors.dart';
import '../../models/chat_model.dart';

class ChatInfoScreen extends StatelessWidget {
  final ChatModel chat;

  const ChatInfoScreen({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: CustomScrollView(
        slivers: [
          // 1. Expanding Header with Profile Image
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: AppColors.primaryTeal,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    chat.name,
                    style: const TextStyle(color: AppColors.textBlack, fontWeight: FontWeight.bold),
                  ),
                 
                ],
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Placeholder for actual image
                  // Container(color: Colors.black87), 
                  const Center(
                    child: Icon(Icons.person, size: 180, color: AppColors.backgroundDark),
                  ),
                ],
              ),
            ),
          ),

          // 2. Info Body Content
          SliverList(
            delegate: SliverChildListDelegate([
              _buildCallActions(context),
              _buildSectionDivider(context),
              
              // Media Section
              _buildMediaSection(context),
              _buildSectionDivider(context),

              // Settings Section
              _buildListTile(context, Icons.notifications, "Mute notifications", 
                trailing: Switch(value: false, onChanged: (v){}, activeThumbColor: AppColors.primaryTeal,inactiveThumbColor: AppColors.appleBlack)),
              _buildListTile(context, Icons.music_note, "Custom notifications"),
              _buildListTile(context, Icons.image, "Media visibility"),
              _buildSectionDivider(context),

              // Specific WhatsApp-style privacy items
              _buildListTile(context, Icons.star_border, "Starred messages", trailing: const Text("5", style: TextStyle(color: Colors.grey))),
              _buildListTile(context, Icons.history, "Disappearing messages", subtitle: "Off"),
              _buildListTile(context, Icons.lock_outline, "Chat lock", 
                trailing: Switch(value: false, onChanged: (v){}, activeThumbColor: AppColors.primaryTeal,inactiveThumbColor: AppColors.appleBlack,), 
                subtitle: "Lock and hide this chat on this device"),
              _buildListTile(context, Icons.security, "Advanced chat privacy", subtitle: "Off"),
              
              _buildSectionDivider(context),
              _buildListTile(context, Icons.favorite_border, "Add to Favorites"),
              _buildListTile(context, Icons.block, "Clear chat", titleColor: Colors.red),
              
              // _buildSectionDivider(context),
              // _buildParticipantHeader(context),
             
              
              const SizedBox(height: 60),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildCallActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _actionButton(context, Icons.phone, "Audio"),
          _actionButton(context, Icons.videocam, "Video"),
          _actionButton(context, Icons.search, "Search"),
        ],
      ),
    );
  }

  Widget _actionButton(BuildContext context, IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryTeal, size: 28),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: AppColors.primaryTeal, fontSize: 14)),
      ],
    );
  }

  Widget _buildMediaSection(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: const Text("Media, links, and docs"),
          trailing: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("177", style: TextStyle(color: Colors.grey)),
              Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
          onTap: () {},
        ),
        SizedBox(
          height: 100,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) => Container(
              width: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryTeal.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                // image: const DecorationImage(
                //   image: NetworkImage("https://via.placeholder.com/100"),
                //   fit: BoxFit.cover,
                // ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSectionDivider(BuildContext context) {
    return Container(
      height: 12,
      color: Theme.of(context).brightness == Brightness.dark 
          ? Colors.black.withOpacity(0.3) 
          : Colors.grey[100],
    );
  }

  Widget _buildListTile(BuildContext context, IconData icon, String title, 
      {Widget? trailing, String? subtitle, Color? titleColor}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(title, style: TextStyle(fontSize: 16, color: titleColor)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)) : null,
      trailing: trailing,
      onTap: () {},
    );
  }

  Widget _buildParticipantHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("2 participants", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          Icon(Icons.search, color: AppColors.primaryTeal),
        ],
      ),
    );
  }

  Widget _buildParticipantTile(BuildContext context, String name, String sub, {bool isMe = false, bool isAdmin = false}) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundImage: NetworkImage("https://via.placeholder.com/150"),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: isAdmin ? Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text("Group Admin", style: TextStyle(fontSize: 10, color: Colors.grey)),
      ) : null,
    );
  }
}