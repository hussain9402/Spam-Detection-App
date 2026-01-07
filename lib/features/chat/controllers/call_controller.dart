import 'package:get/get.dart';
import '../models/call_model.dart';

class CallController extends GetxController {
  final RxList<CallModel> calls = <CallModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadDummyData();
  }

  void _loadDummyData() {
    final now = DateTime.now();
    calls.value = [
      CallModel(
        id: '1',
        name: 'Team Align',
        type: CallType.incoming,
        callTime: DateTime(now.year, now.month, now.day, 9, 30),
        isGroup: true,
      ),
      CallModel(
        id: '2',
        name: 'Jhon Abraham',
        type: CallType.incoming,
        callTime: DateTime(now.year, now.month, now.day, 7, 30),
      ),
      CallModel(
        id: '3',
        name: 'Sabila Sayma',
        type: CallType.missed,
        callTime: DateTime(now.year, now.month, now.day - 1, 19, 35),
      ),
      CallModel(
        id: '4',
        name: 'Alex Linderson',
        type: CallType.outgoing,
        callTime: DateTime(now.year, now.month, now.day - 2, 9, 30),
      ),
      CallModel(
        id: '5',
        name: 'Jhon Abraham',
        type: CallType.missed,
        callTime: DateTime(2022, 7, 3, 7, 30),
      ),
      CallModel(
        id: '6',
        name: 'John Borino',
        type: CallType.outgoing,
        callTime: DateTime(now.year, now.month, now.day - 2, 9, 30),
      ),
    ];
  }

  String _formatCallTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final callDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    final timeStr = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.hour >= 12 ? 'PM' : 'AM'}';

    if (callDate == today) {
      return 'Today, $timeStr';
    } else if (callDate == yesterday) {
      return 'Yesterday, $timeStr';
    } else {
      final daysDiff = now.difference(callDate).inDays;
      if (daysDiff < 7) {
        final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
        return '${weekdays[dateTime.weekday - 1]}, $timeStr';
      } else {
        return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year.toString().substring(2)}, $timeStr';
      }
    }
  }

  String formatCallTime(DateTime dateTime) => _formatCallTime(dateTime);
}

