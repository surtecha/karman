import 'package:flutter/cupertino.dart';
import 'package:karman_app/app_state.dart';
import 'package:karman_app/core/services/database/database_service.dart';
import 'package:karman_app/core/services/notifications/notification_service.dart';
import 'package:karman_app/core/services/notifications/pomodoro_notification_service.dart';
import 'package:karman_app/features/habits/logic/habit_controller.dart';
import 'package:karman_app/features/tasks/logic/task_controller.dart';
import 'package:karman_app/features/welcome_tutorial/ui/pages/welcome/welcome_service.dart';
import 'package:karman_app/karman_app.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  await NotificationService.init(navigatorKey);
  await PomodoroNotificationService.initialize();
  tz.initializeTimeZones();

  final databaseService = DatabaseService();
  await databaseService.ensureInitialized();

  final taskController = TaskController();
  final habitController = HabitController();

  await taskController.loadTasks();
  await habitController.loadHabits();

  final shouldShowWelcome = await WelcomeService.shouldShowWelcomeScreen();

  final prefs = await SharedPreferences.getInstance();
  final lastUsedTabIndex = prefs.getInt('lastUsedTabIndex') ?? 1;

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => taskController),
      ChangeNotifierProvider(create: (context) => habitController),
      ChangeNotifierProvider(create: (context) => AppState()),
    ],
    child: KarmanApp(
      navigatorKey: navigatorKey,
      showWelcome: shouldShowWelcome,
      initialTabIndex: lastUsedTabIndex,
    ),
  ));
}
