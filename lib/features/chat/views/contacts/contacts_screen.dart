import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spamdetection/core/constants/app_colors.dart';
import 'package:spamdetection/core/constants/app_strings.dart';
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
    final ContactsController controller = Get.put(ContactsController());

    return Scaffold(
      backgroundColor: AppColors.headerDarkGreen, // Match header color
      body: SafeArea(
        child: Column(
          children: [
            // --- 1. HEADER (Title at center) ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              color: AppColors.headerDarkGreen,
              child: Row(
                children: [
                  // IconButton(
                  //   icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
                  //   onPressed: () => Navigator.of(context).pop(),
                  // ),
                  const Expanded(
                    child: Text(
                      AppStrings.contacts,
                      style: TextStyle(
                        color: AppColors.primaryTeal,
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // IconButton(
                  //   icon: const Icon(Icons.refresh, color: AppColors.textWhite),
                  //   onPressed: () => controller.loadContacts(),
                  // ),
                ],
              ),
            ),

            // --- 2. MAIN CONTENT (Curved Container) ---
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    
                    // --- 3. SEARCH FIELD (Inside curved part) ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.grey[900] 
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextField(
                          controller: searchController,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                          decoration: InputDecoration(
                            hintText: 'Search contacts...',
                            hintStyle: const TextStyle(color: Colors.grey),
                            prefixIcon: const Icon(Icons.search, color: Colors.grey),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                searchController.clear();
                                searchQuery.value = '';
                              },
                            ),
                          ),
                          onChanged: (value) => searchQuery.value = value.toLowerCase(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // --- 4. CONTACTS LIST ---
                    Expanded(
                      child: Obx(() {
                        if (controller.isLoading.value && controller.contacts.isEmpty) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (controller.contacts.isEmpty) {
                          return const Center(child: Text('No contacts found.'));
                        }

                        final allFiltered = controller.contacts.where((contactModel) {
                          final name = contactModel.contact.displayName.toLowerCase();
                          final phone = contactModel.phoneNumber.toLowerCase();
                          final query = searchQuery.value;
                          return name.contains(query) || phone.contains(query);
                        }).toList();

                        if (allFiltered.isEmpty) {
                          return const Center(child: Text('No matching contacts.'));
                        }

                        final appUsers = allFiltered.where((c) => c.isAppUser).toList();
                        final others = allFiltered.where((c) => !c.isAppUser).toList();

                        // Sorting
                        appUsers.sort((a, b) => a.contact.displayName.toLowerCase().compareTo(b.contact.displayName.toLowerCase()));
                        others.sort((a, b) => a.contact.displayName.toLowerCase().compareTo(b.contact.displayName.toLowerCase()));

                        final finalSortedList = [...appUsers, ...others];

                        return ListView.builder(
                          padding: const EdgeInsets.only(bottom: 20),
                          itemCount: finalSortedList.length,
                          itemBuilder: (context, index) {
                            final contactModel = finalSortedList[index];
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
                                    padding: const EdgeInsets.fromLTRB(24, 20, 16, 8),
                                    child: Text(
                                      contactModel.isAppUser ? "CONTACTS ON APP" : "INVITE TO APP",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.grey[700],
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
            ),
          ],
        ),
      ),
    );
  }

  // --- Tile Builder ---
  Widget _buildContactTile(dynamic contact, String phone, bool isAppUser) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      onTap: isAppUser ? () {
        final String? myPhone = Get.find<AuthController>().currentUser.value?.phoneNumber;
        if (myPhone == null) return;

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

        Get.to(() => ChatDetailScreen(chat: chatModel), transition: Transition.rightToLeft);
      } : null,
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.yellow[700]?.withOpacity(0.1),
        child: Icon(Icons.person, color: Colors.yellow[700], size: 28),
      ),
      title: Text(
        contact.displayName.isNotEmpty ? contact.displayName : 'Unnamed',
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      subtitle: Text(phone, style: const TextStyle(color: Colors.grey, fontSize: 14)),
      trailing: isAppUser
          ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
          : TextButton(
              onPressed: () {},
              child: const Text('Invite', style: TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold)),
            ),
    );
  }
}