import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';class ContactModel {
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
          // Never trust cached flags — avoids "Invite" when user is on the app (or the reverse).
          isAppUser: false,
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
        final phone = _bestPhoneForContact(contact);
        return ContactModel(
          contact: contact,
          isAppUser: _contactHasRegisteredPhone(contact),
          phoneNumber: phone,
        );
      }).toList();

      // Always refresh: Firestore app-user set may change without contact count changing.
      contacts.assignAll(fetchedModels);
      _saveToCache(fetchedModels);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadFirestoreUserPhones() async {
    const tag = 'FirestoreRead.users';
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      developer.log(
        'Skipped users.get() — no Firebase Auth user yet (cannot read Firestore as you).',
        name: tag,
      );
      print('[$tag] SKIPPED: not signed in');
      return;
    }

    try {
      developer.log('Query: collection("users").get() as uid=$uid', name: tag);
      print('[$tag] Fetching users… (signed in as $uid)');

      // Prefer server so we don’t keep an old offline cache that only had your own doc
      // (common after Firestore rules were updated).
      QuerySnapshot<Map<String, dynamic>> snapshot;
      try {
        snapshot = await _firestore
            .collection('users')
            .get(const GetOptions(source: Source.server));
      } on FirebaseException catch (e) {
        if (e.code == 'unavailable' ||
            e.code == 'failed-precondition' ||
            e.code == 'deadline-exceeded') {
          developer.log(
            'Server fetch failed (${e.code}), retrying with default source.',
            name: tag,
          );
          print('[$tag] Server fetch failed (${e.code}), using cache+server');
          snapshot = await _firestore.collection('users').get();
        } else {
          rethrow;
        }
      }

      final ids = snapshot.docs.map((d) => d.id).join(', ');
      final fromCache = snapshot.metadata.isFromCache;
      final pending = snapshot.metadata.hasPendingWrites;

      developer.log(
        'Snapshot: ${snapshot.docs.length} document(s), fromCache=$fromCache, '
        'hasPendingWrites=$pending, ids=[$ids]',
        name: tag,
      );
      print(
        '[$tag] Got ${snapshot.docs.length} user doc(s) | fromCache=$fromCache | ids: $ids',
      );

      if (snapshot.docs.length <= 1) {
        print(
          '[$tag] WARNING: Only ${snapshot.docs.length} profile(s). '
          'If others signed up but are missing: (1) Deploy firestore.rules '
          '(allow read on users for any signed-in user). (2) Confirm those '
          'accounts exist in Firebase Console → Firestore → users.',
        );
        developer.log(
          'Only ${snapshot.docs.length} user document(s) returned. '
          'Rules may still be owner-only on the server, or no other users exist.',
          name: tag,
        );
      }

      _appUserPhones = {};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        developer.log(
          'Doc users/${doc.id} data: $data',
          name: tag,
        );
        print('[$tag] users/${doc.id} => phone field: ${data['phone'] ?? data['phoneNumber']}');
        final raw = data['phone'] ?? data['phoneNumber'];
        if (raw == null) {
          developer.log(
            '  → skipped (no phone / phoneNumber field)',
            name: tag,
          );
          continue;
        }
        _registerKnownAppPhone(raw.toString());
        developer.log(
          '  → registered for matching: "${raw.toString()}"',
          name: tag,
        );
      }

      developer.log(
        'Lookup keys built: ${_appUserPhones.length} (includes tails / variants)',
        name: tag,
      );
      print('[$tag] Lookup keys: ${_appUserPhones.length}');
    } on FirebaseException catch (e, st) {
      developer.log(
        'FirebaseException: ${e.code} — $e',
        name: tag,
        error: e,
        stackTrace: st,
      );
      print('[$tag] FirebaseException [${e.code}]: $e');
      if (e.code == 'permission-denied') {
        print(
          '[$tag] >>> collection("users").get() is BLOCKED by Firestore rules on the SERVER. <<<',
        );
        print(
          '[$tag] Fix: Firebase Console → Firestore → Rules → for path users/{userId} use:',
        );
        print(
          '[$tag]   allow read: if request.auth != null;',
        );
        print(
          '[$tag] Then Publish. Or run: firebase deploy --only firestore:rules',
        );
        print(
          '[$tag] Note: The rules file in your project folder is NOT used until deployed.',
        );
      }
    } catch (e, st) {
      developer.log(
        'ERROR: $e',
        name: tag,
        error: e,
        stackTrace: st,
      );
      print('[$tag] ERROR: $e');
    }
  }

  void _registerKnownAppPhone(String raw) {
    final digits = _normalizeToDigits(raw);
    if (digits.isEmpty) return;
    _appUserPhones.add(digits);
    if (digits.startsWith('00')) {
      final without00 = digits.substring(2);
      if (without00.isNotEmpty) _appUserPhones.add(without00);
    }
    if (digits.length >= 10) {
      _appUserPhones.add(_mobileTail(digits));
    }
  }

  static String _digitsOnly(String s) => s.replaceAll(RegExp(r'[^\d]'), '');

  /// Strip tel: / spaces; keep only digits (ASCII).
  static String _normalizeToDigits(String phone) {
    var s = phone.trim();
    if (s.toLowerCase().startsWith('tel:')) {
      s = s.substring(4).trim();
    }
    return _digitsOnly(s);
  }

  /// Last 10 digits — aligns local (03…) with E.164 (+923…) style entries.
  static String _mobileTail(String digits) {
    if (digits.length <= 10) return digits;
    return digits.substring(digits.length - 10);
  }

  /// True if this single number string matches any registered user.
  bool _isPhoneInApp(String phone) {
    if (phone.isEmpty) return false;
    final clean = _normalizeToDigits(phone);
    if (clean.isEmpty) return false;

    if (_appUserPhones.contains(clean)) return true;

    if (clean.length >= 10) {
      final tail = _mobileTail(clean);
      if (_appUserPhones.contains(tail)) return true;
    }

    for (final appEntry in _appUserPhones) {
      if (appEntry.length < 7) continue;
      if (clean == appEntry) return true;
      if (clean.length >= 10 &&
          appEntry.length >= 10 &&
          _mobileTail(clean) == _mobileTail(appEntry)) {
        return true;
      }
    }
    return false;
  }

  /// Any saved number on this contact may be the one that matches Firestore.
  bool _contactHasRegisteredPhone(Contact contact) {
    for (final p in contact.phones) {
      if (_isPhoneInApp(p.number)) return true;
    }
    return false;
  }

  /// Prefer a number that matches the app (for chat id / display); else first non-empty.
  String _bestPhoneForContact(Contact contact) {
    if (contact.phones.isEmpty) return '';
    for (final p in contact.phones) {
      if (_isPhoneInApp(p.number)) return p.number;
    }
    return contact.phones.first.number;
  }
}