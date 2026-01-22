import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';

class ContactsController extends GetxController {
  RxList<Contact> contacts = <Contact>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadContacts(); // Load contacts when controller initializes
  }

  Future<void> loadContacts() async {
    isLoading.value = true;

    // Request permission
    bool granted = await FlutterContacts.requestPermission();
    if (!granted) {
      Get.snackbar(
        'Permission denied',
        'Go to app settings to allow contacts access',
        snackPosition: SnackPosition.BOTTOM,
      );
      isLoading.value = false;
      return;
    }

    // Fetch contacts with phone numbers
    List<Contact> _contacts = await FlutterContacts.getContacts(
      withProperties: true,  // important for phones/emails
      withThumbnail: false,  // optional
    );

    // Optional: sort contacts by displayName
    _contacts.sort((a, b) => a.displayName.compareTo(b.displayName));

    contacts.value = _contacts;
  }}