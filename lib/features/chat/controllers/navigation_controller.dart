import 'package:get/get.dart';

class NavigationController extends GetxController {
  static const int messagesTabIndex = 0;

  final RxInt currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
  }

  /// Select the Messages (home) tab — use when leaving pushed routes so the shell opens on Chats.
  void goToMessagesTab() {
    currentIndex.value = messagesTabIndex;
  }
}

