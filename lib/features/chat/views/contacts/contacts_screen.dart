import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spamdetection/core/constants/app_colors.dart';
import 'package:spamdetection/features/authentication/controllers/auth_controller.dart';
import 'package:spamdetection/shared/services/contacts_service.dart';
import '../../models/chat_model.dart';
import '../chat_detail/chat_detail_screen.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  late TextEditingController searchController;
  RxString searchQuery = ''.obs;
  RxBool isSearching = false.obs;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Controller handles the background sync and caching logic
    final ContactsController controller = Get.put(ContactsController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Obx(() => isSearching.value
            ? TextField(
                controller: searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                decoration: const InputDecoration(
                  hintText: 'Search contacts...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                onChanged: (value) {
                  searchQuery.value = value.toLowerCase();
                },
              )
            : const Text(
                'Contacts',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )),
        actions: [
          Obx(() => isSearching.value
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    isSearching.value = false;
                    searchController.clear();
                    searchQuery.value = '';
                  },
                )
              : Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => isSearching.value = true,
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () => controller.loadContacts(),
                    ),
                  ],
                )),
        ],
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                // Show loading only if we have no cached data yet
                if (controller.isLoading.value && controller.contacts.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.contacts.isEmpty) {
                  return const Center(child: Text('No contacts found.'));
                }

                // 1. Filter based on Search Query
                final allFiltered = controller.contacts.where((contactModel) {
                  final name = contactModel.contact.displayName.toLowerCase();
                  final phone = contactModel.phoneNumber.toLowerCase();
                  final query = searchQuery.value;
                  return name.contains(query) || phone.contains(query);
                }).toList();

                if (allFiltered.isEmpty) {
                  return const Center(child: Text('No contacts match your search.'));
                }

                // 2. Split into App Users and others
                final appUsers = allFiltered.where((c) => c.isAppUser).toList();
                final others = allFiltered.where((c) => !c.isAppUser).toList();

                // 3. Alphabetical Sort
                appUsers.sort((a, b) => a.contact.displayName
                    .toLowerCase()
                    .compareTo(b.contact.displayName.toLowerCase()));
                others.sort((a, b) => a.contact.displayName
                    .toLowerCase()
                    .compareTo(b.contact.displayName.toLowerCase()));

                // 4. Final list construction
                final finalSortedList = [...appUsers, ...others];

                return ListView.builder(
                  itemCount: finalSortedList.length,
                  itemBuilder: (context, index) {
                    final contactModel = finalSortedList[index];

                    // Section Headers Logic
                    bool showHeader = false;
                    if (index == 0 && contactModel.isAppUser) {
                      showHeader = true;
                    } else if (index == appUsers.length && others.isNotEmpty) {
                      showHeader = true;
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showHeader)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                            child: Text(
                              contactModel.isAppUser ? "CONTACTS ON APP" : "INVITE TO APP",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textWhite,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        _buildContactTile(
                          contactModel.contact,
                          contactModel.phoneNumber,
                          contactModel.isAppUser,
                        ),
                      ],
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTile(dynamic contact, String phone, bool isAppUser) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: isAppUser
          ? () {
              final String? myPhone = Get.find<AuthController>().currentUser.value?.phoneNumber;
              if (myPhone == null || myPhone.isEmpty) {
                Get.snackbar("Error", "Your phone number is missing.");
                return;
              }

              List<String> numbers = [myPhone, phone];
              numbers.sort();
              String uniqueChatId = "${numbers[0]}_${numbers[1]}";

              final chatModel = ChatModel(
                id: uniqueChatId,
                name: contact.displayName.isNotEmpty ? contact.displayName : 'Unnamed',
                lastMessage: '',
                lastMessageTime: DateTime.now(),
                unreadCount: 0,
                isGroup: false,
                phoneNumber: phone,
                senderPhone: myPhone,
              );

              // Use Get.to to keep navigation natural
              Get.to(
                () => ChatDetailScreen(chat: chatModel),
                transition: Transition.rightToLeft,
              );
            }
          : null,
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.yellow[700]?.withAlpha(50),
        child: Icon(Icons.person, color: Colors.yellow[700], size: 28),
      ),
      title: Text(
        contact.displayName.isNotEmpty ? contact.displayName : 'Unnamed',
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      subtitle: Text(
        phone,
        style: const TextStyle(color: Colors.grey, fontSize: 14),
      ),
      trailing: isAppUser
          ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
          : TextButton(
              onPressed: () {
                // Optional: Implement Invite Logic (SMS/Share)
              },
              child: const Text(
                'Invite',
                style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold),
              ),
            ),
    );
  }
}