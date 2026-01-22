import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spamdetection/core/constants/app_colors.dart';
import 'package:spamdetection/shared/services/contacts_service.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ContactsController controller = Get.put(ContactsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        backgroundColor: AppColors.textBlack,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } 
        if (controller.contacts.isEmpty) {
          return const Center(child: Text('No contacts found.'));
        }

        return ListView.builder(
          itemCount: controller.contacts.length,
          itemBuilder: (context, index) {
            final contact = controller.contacts[index];
            final phone = contact.phones.isNotEmpty
                ? contact.phones.first.number
                : 'No number';

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryTeal,
                foregroundColor: AppColors.textWhite,
                // child: Text(contact.initials()),
              ),
              title: Text(contact.displayName.isNotEmpty
                  ? contact.displayName
                  : 'Unnamed'),
              subtitle: Text(phone),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.refresh),
        onPressed: () => controller.loadContacts(),
      ),
    );
  }
}
