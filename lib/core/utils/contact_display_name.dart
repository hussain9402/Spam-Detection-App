import 'package:get/get.dart';

import '../../shared/services/contacts_service.dart';

/// Prefer how **you** saved the number in the phone app over Firestore [otherUserName]
/// (which reflects the other person\'s profile / their side).
class ContactDisplayName {
  static String _digitsOnly(String s) => s.replaceAll(RegExp(r'[^\d]'), '');

  static String _normalizeToDigits(String phone) {
    var s = phone.trim();
    if (s.toLowerCase().startsWith('tel:')) {
      s = s.substring(4).trim();
    }
    return _digitsOnly(s);
  }

  static String _mobileTail(String digits) {
    if (digits.length <= 10) {
      return digits;
    }
    return digits.substring(digits.length - 10);
  }

  static bool phonesMatch(String a, String b) {
    final String da = _normalizeToDigits(a);
    final String db = _normalizeToDigits(b);
    if (da.isEmpty || db.isEmpty) {
      return false;
    }
    if (da == db) {
      return true;
    }
    if (da.length >= 10 && db.length >= 10) {
      if (_mobileTail(da) == _mobileTail(db)) {
        return true;
      }
    }
    final String long = da.length >= db.length ? da : db;
    final String short = da.length < db.length ? da : db;
    if (short.length >= 7 && long.length > short.length) {
      if (long.endsWith(short)) {
        return true;
      }
      if (long.length >= 10 && short.length >= 10) {
        if (long.endsWith(_mobileTail(short)) ||
            _mobileTail(long).endsWith(_mobileTail(short))) {
          return true;
        }
      }
    }
    return false;
  }

  static String? deviceContactNameForPhone(String rawPhone) {
    if (!Get.isRegistered<ContactsController>()) {
      return null;
    }
    final ContactsController cc = Get.find<ContactsController>();
    for (final ContactModel cm in cc.contacts) {
      if (phonesMatch(rawPhone, cm.phoneNumber)) {
        final String n = cm.contact.displayName.trim();
        if (n.isNotEmpty) {
          return n;
        }
      }
      for (final p in cm.contact.phones) {
        if (phonesMatch(rawPhone, p.number)) {
          final String n = cm.contact.displayName.trim();
          if (n.isNotEmpty) {
            return n;
          }
        }
      }
    }
    return null;
  }

  /// 1) Your phone contact name for [otherPhone] 2) [fromFirestore] 3) [otherPhone] string
  static String chatListTitle({
    required String otherPhone,
    String? fromFirestore,
  }) {
    final String? contact = deviceContactNameForPhone(otherPhone);
    if (contact != null && contact.isNotEmpty) {
      return contact;
    }
    final String s = (fromFirestore ?? '').trim();
    if (s.isNotEmpty) {
      return s;
    }
    return otherPhone;
  }
}
