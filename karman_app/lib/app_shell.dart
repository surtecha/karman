import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:karman_app/pages/habit/habits_page.dart';
import 'package:karman_app/pages/task/tasks_page.dart';
import 'package:karman_app/pages/focus/focus_page.dart';

class AppShell extends StatefulWidget {
  static final GlobalKey<AppShellState> globalKey = GlobalKey<AppShellState>();

  const AppShell({super.key});

  @override
  AppShellState createState() => AppShellState();
}

class AppShellState extends State<AppShell> {
  final CupertinoTabController _controller =
      CupertinoTabController(initialIndex: 1);

  void switchToTab(int index) {
    setState(() {
      _controller.index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      controller: _controller,
      tabBar: CupertinoTabBar(
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
          default:
            return CupertinoTabView(builder: (context) => TasksPage());
        }
      },
    );
  }
}
