import 'package:flutter/cupertino.dart';
import 'package:karman/theme/color_scheme.dart';
import 'package:karman/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:karman/screens/habits/habits_screen.dart';
import 'package:karman/screens/more/more_screen.dart';
import 'package:karman/screens/pomodoro/pomodoro_screen.dart';
import 'package:karman/screens/settings/settings_screen.dart';
import 'package:karman/screens/todo/todo_screen.dart';
import 'package:karman/services/notifications/notification_navigation_service.dart';

class NavigationWrapper extends StatefulWidget {
  const NavigationWrapper({super.key});

  @override
  State<NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper> {
  final NotificationNavigationService _navigationService =
      NotificationNavigationService();
  late CupertinoTabController _tabController;

  static const List<Widget> _pages = [
    MoreScreen(),
    PomodoroScreen(),
    TodoScreen(),
    HabitsScreen(),
    SettingsScreen(),
  ];

  static const List<BottomNavigationBarItem> _tabItems = [
    BottomNavigationBarItem(
      icon: Icon(CupertinoIcons.square_grid_2x2),
      label: 'More',
    ),
    BottomNavigationBarItem(
      icon: Icon(CupertinoIcons.timer),
      label: 'Pomodoro',
    ),
    BottomNavigationBarItem(
      icon: Icon(CupertinoIcons.check_mark_circled),
      label: 'Todo',
    ),
    BottomNavigationBarItem(
      icon: Icon(CupertinoIcons.graph_circle),
      label: 'Habits',
    ),
    BottomNavigationBarItem(
      icon: Icon(CupertinoIcons.settings),
      label: 'Settings',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = CupertinoTabController(initialIndex: 2);
    _navigationService.setTabController(_tabController);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, child) {
        return CupertinoTabScaffold(
          controller: _tabController,
          tabBar: CupertinoTabBar(
            activeColor: AppColorScheme.accent(theme, context),
            backgroundColor: AppColorScheme.backgroundPrimary(theme),
            border: null,
            items: _tabItems,
          ),
          tabBuilder: (context, index) {
            return CupertinoTabView(builder: (context) => _pages[index]);
          },
        );
      },
    );
  }
}
