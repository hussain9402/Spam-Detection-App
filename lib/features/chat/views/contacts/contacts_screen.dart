import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../controllers/contact_controller.dart';
import '../../models/contact_model.dart';
import '../profile/profile_screen.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ContactController controller = Get.put(ContactController());
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
                      localizations.contacts,
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_add, color: AppColors.textWhite),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            
            // Contacts List
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
                        localizations.myContact,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    
                    Expanded(
                      child: Obx(() {
                        final groupedContacts = controller.getGroupedContacts();
                        final sortedKeys = groupedContacts.keys.toList();

                        return ListView.builder(
                          padding: const EdgeInsets.only(top: 8),
                          itemCount: sortedKeys.length,
                          itemBuilder: (context, index) {
                            final key = sortedKeys[index];
                            final contacts = groupedContacts[key]!;
                            
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Alphabet Header
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 16,
                                    top: 16,
                                    bottom: 8,
                                  ),
                                  child: Text(
                                    key,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                
                                // Contacts in this group
                                ...contacts.map((contact) => 
                                  _buildContactItem(context, contact)
                                ).toList(),
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

  Widget _buildContactItem(BuildContext context, ContactModel contact) {
    return InkWell(
      onTap: () {
        Get.to(() => ProfileScreen(contact: contact));
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
                color: AppColors.headerDarkGreen,
              ),
              child: const Icon(
                Icons.person,
                color: AppColors.textWhite,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            
            // Contact Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    contact.status,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textLightGray,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

