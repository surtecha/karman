import 'package:flutter/cupertino.dart';
import 'package:karman_app/features/foucs/ui/pages/focus_page.dart';
import 'package:karman_app/features/habits/ui/pages/habits_page.dart';
import 'package:karman_app/features/more/ui/pages/more_page.dart';
import 'package:karman_app/features/tasks/ui/pages/tasks_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppShell extends StatefulWidget {
  static final GlobalKey<AppShellState> globalKey = GlobalKey<AppShellState>();
  final int initialTabIndex;

  const AppShell({super.key, required this.initialTabIndex});

  @override
  AppShellState createState() => AppShellState();
}

class AppShellState extends State<AppShell> {
  late final CupertinoTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CupertinoTabController(initialIndex: widget.initialTabIndex);
    _controller.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTabChange);
    _controller.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    _saveLastUsedTabIndex(_controller.index);
  }

  Future<void> _saveLastUsedTabIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastUsedTabIndex', index);
  }

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
        height: 60,
        border: null,
        items: const [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 8),
              child: Icon(CupertinoIcons.repeat),
            ),
            label: 'Habit',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 8),
              child: Icon(CupertinoIcons.list_bullet),
            ),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 8),
              child: Icon(CupertinoIcons.hourglass),
            ),
            label: 'Focus',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 8),
              child: Icon(CupertinoIcons.square_grid_2x2),
            ),
            label: 'More',
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
          case 3:
            return CupertinoTabView(builder: (context) => MorePage());
          default:
            return CupertinoTabView(builder: (context) => TasksPage());
        }
      },
    );
  }
}
