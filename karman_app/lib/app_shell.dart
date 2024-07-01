import 'package:flutter/cupertino.dart';
import 'package:karman_app/pages/habit/habits_page.dart';
import 'package:karman_app/pages/pomodoro/pomodoro_page.dart';
import 'package:karman_app/pages/setting/settings_page.dart';
import 'package:karman_app/pages/tasks/tasks_page.dart';
import 'package:karman_app/pages/zen/zen_page.dart';

class AppShell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: CupertinoColors.black,
        activeColor: CupertinoColors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.check_mark_circled),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.clock),
            label: 'Habit',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.circle),
            label: 'Zen',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.timer),
            label: 'Pomodoro',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            label: 'Settings',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return CupertinoTabView(builder: (context) => TasksPage());
          case 1:
            return CupertinoTabView(builder: (context) => HabitsPage());
          case 2:
            return CupertinoTabView(builder: (context) => ZenPage());
          case 3:
            return CupertinoTabView(builder: (context) => PomodoroPage());
          case 4:
            return CupertinoTabView(builder: (context) => SettingsPage());
          default:
            return CupertinoTabView(builder: (context) => TasksPage());
        }
      },
    );
  }
}
