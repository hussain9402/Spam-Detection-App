import 'package:get/get.dart';
import '../models/spam_model.dart';

class SpamController extends GetxController {
  final RxList<SpamMessage> spamMessages = <SpamMessage>[].obs;
  final RxInt blockedCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadDummySpamData();
  }

  void _loadDummySpamData() {
    spamMessages.value = [
      SpamMessage(
        id: '1',
        senderName: 'Unknown Number',
        senderPhone: '+1 (555) 123-4567',
        category: 'Unknown Number',
        messageContent: 'Congratulations! You won \$1,000,000. Click here to claim...',
        receivedTime: DateTime.now().subtract(const Duration(hours: 24)),
        riskLevel: SpamRiskLevel.high,
        blockedCount: 0,
      ),
      SpamMessage(
        id: '2',
        senderName: 'Promotional',
        senderPhone: '+1 (555) 987-6543',
        category: 'Promotional',
        messageContent: 'URGENT: Your account will be suspended. Verify now at...',
        receivedTime: DateTime.now().subtract(const Duration(days: 2)),
        riskLevel: SpamRiskLevel.high,
        blockedCount: 0,
      ),
      SpamMessage(
        id: '3',
        senderName: 'Spam Bot',
        senderPhone: '+1 (555) 444-5555',
        category: 'Spam Bot',
        messageContent: 'Free iPhone 15! Limited offer. Reply YES to claim your prize...',
        receivedTime: DateTime.now().subtract(const Duration(days: 3)),
        riskLevel: SpamRiskLevel.medium,
        blockedCount: 0,
      ),
    ];
    _updateBlockedCount();
  }

  void _updateBlockedCount() {
    blockedCount.value = spamMessages.length;
  }

  void deleteSpamMessage(String id) {
    spamMessages.removeWhere((msg) => msg.id == id);
    _updateBlockedCount();
  }

  void restoreSpamMessage(String id) {
    // Restore to messages (implement as needed)
    deleteSpamMessage(id);
  }

  String _getTimeString(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else {
      return '${(difference.inDays / 30).floor()} months ago';
    }
  }
}
