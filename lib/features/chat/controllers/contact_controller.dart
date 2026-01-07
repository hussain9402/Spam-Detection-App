import 'package:get/get.dart';
import '../models/contact_model.dart';

class ContactController extends GetxController {
  final RxList<ContactModel> contacts = <ContactModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadDummyData();
  }

  void _loadDummyData() {
    contacts.value = [
      ContactModel(
        id: '1',
        name: 'Afrin Sabila',
        status: 'Life is beautiful 💪',
      ),
      ContactModel(
        id: '2',
        name: 'Adil Adnan',
        status: 'Be your own hero 💪',
      ),
      ContactModel(
        id: '3',
        name: 'Bristy Haque',
        status: 'Keep working 💪',
      ),
      ContactModel(
        id: '4',
        name: 'John Borino',
        status: 'Make yourself proud 🥰',
      ),
      ContactModel(
        id: '5',
        name: 'Borsha Akther',
        status: 'Flowers are beautiful 🌸',
      ),
      ContactModel(
        id: '6',
        name: 'sheik Sadi',
        status: 'Stay positive ✨',
      ),
    ];
  }

  Map<String, List<ContactModel>> getGroupedContacts() {
    final Map<String, List<ContactModel>> grouped = {};
    
    for (var contact in contacts) {
      final firstLetter = contact.name[0].toUpperCase();
      if (!grouped.containsKey(firstLetter)) {
        grouped[firstLetter] = [];
      }
      grouped[firstLetter]!.add(contact);
    }

    // Sort contacts within each group
    grouped.forEach((key, value) {
      value.sort((a, b) => a.name.compareTo(b.name));
    });

    // Sort groups alphabetically
    final sortedKeys = grouped.keys.toList()..sort();
    final sortedMap = <String, List<ContactModel>>{};
    for (var key in sortedKeys) {
      sortedMap[key] = grouped[key]!;
    }

    return sortedMap;
  }
}

