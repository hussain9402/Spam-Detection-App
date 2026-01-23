import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';

class ContactModel {
  final Contact contact;
  final bool isAppUser;
  final String phoneNumber;

  ContactModel({
    required this.contact,
    required this.isAppUser,
    required this.phoneNumber,
  });
}

class ContactsController extends GetxController {
  RxList<ContactModel> contacts = <ContactModel>[].obs;
  RxBool isLoading = false.obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _box = GetStorage();
  Set<String> _appUserPhones = {};

@override
void onInit() {
  super.onInit(); // Call the super of GetxController
  _loadFromCache();
  loadContacts();
}

  // --- PERSISTENCE LOGIC ---

  void _loadFromCache() {
    final List<dynamic>? cachedData = _box.read<List<dynamic>>('contacts_cache');
    if (cachedData != null && contacts.isEmpty) {
      final List<ContactModel> mapped = cachedData.map((item) {
        return ContactModel(
          contact: Contact(displayName: item['name']),
          phoneNumber: item['phone'],
          isAppUser: item['isAppUser'] ?? false,
        );
      }).toList();
      contacts.assignAll(mapped);
    }
  }

  void _saveToCache(List<ContactModel> list) {
    final cacheList = list.map((c) => {
      'name': c.contact.displayName,
      'phone': c.phoneNumber,
      'isAppUser': c.isAppUser,
    }).toList();
    _box.write('contacts_cache', cacheList);
  }

  // --- SYNC LOGIC ---

  Future<void> loadContacts() async {
    try {
      if (contacts.isEmpty) isLoading.value = true;

      // Sync Firestore users
      await _loadFirestoreUserPhones();
      
      bool granted = await FlutterContacts.requestPermission();
      if (!granted) return;

      List<Contact> deviceContacts = await FlutterContacts.getContacts(
        withProperties: true,
        withThumbnail: false,
      );

      final List<ContactModel> fetchedModels = deviceContacts.map((contact) {
        final phone = contact.phones.isNotEmpty ? contact.phones.first.number : '';
        return ContactModel(
          contact: contact,
          isAppUser: _isPhoneInApp(phone),
          phoneNumber: phone,
        );
      }).toList();

      // Only update and cache if data has changed to prevent UI flicker
      if (contacts.length != fetchedModels.length) {
        contacts.assignAll(fetchedModels);
        _saveToCache(fetchedModels);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadFirestoreUserPhones() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      _appUserPhones = snapshot.docs
          .map((doc) => doc['phone'] as String)
          .where((p) => p.isNotEmpty)
          .toSet();
    } catch (e) {
      print('Firestore sync error: $e');
    }
  }

  bool _isPhoneInApp(String phone) {
    if (phone.isEmpty) return false;
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    return _appUserPhones.any((appPhone) => 
        appPhone.replaceAll(RegExp(r'[^\d]'), '') == cleanPhone);
  }
}