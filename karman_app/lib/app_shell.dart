import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:karman_app/pages/habit/habits_page.dart';
// import 'package:karman_app/pages/setting/settings_page.dart';
import 'package:karman_app/pages/task/tasks_page.dart';
import 'package:karman_app/pages/focus/focus_page.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        currentIndex: 1,
        iconSize: 32,
        backgroundColor: CupertinoColors.black,
        activeColor: CupertinoColors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.leaf_arrow_circlepath),
            label: 'Habit',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.check_mark_circled),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.self_improvement_outlined),
            label: 'Focus',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(CupertinoIcons.gear),
          //   label: 'Settings',
          // ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return CupertinoTabView(builder: (context) => HabitsPage());
          case 1:
            return CupertinoTabView(builder: (context) => TasksPage());
          case 2:
            return CupertinoTabView(builder: (context) => FocusPage());
          // case 3:
          //   return CupertinoTabView(builder: (context) => SettingsPage());
          default:
            return CupertinoTabView(builder: (context) => TasksPage());
        }
      },
    );
  }
}
