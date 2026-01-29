import 'package:flutter/cupertino.dart';

class NotificationNavigationService {
  static final NotificationNavigationService _instance =
      NotificationNavigationService._internal();
  factory NotificationNavigationService() => _instance;
  NotificationNavigationService._internal();

  CupertinoTabController? _tabController;

  void setTabController(CupertinoTabController controller) {
    _tabController = controller;
  }

  void navigateToTodos() {
    _tabController?.index = 2;
  }

  void navigateToHabits() {
    _tabController?.index = 3;
  }

  void handleNotificationTap(String? payload) {
    if (payload == null) return;

    if (payload.startsWith('todo')) {
      navigateToTodos();
    } else if (payload.startsWith('habit')) {
      navigateToHabits();
    }
  }
}
