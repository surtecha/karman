import 'package:flutter/cupertino.dart';
import 'package:karman_app/app_shell.dart';
import 'package:karman_app/controllers/habit/habit_controller.dart';
import 'package:karman_app/controllers/task/task_controller.dart';
import 'package:karman_app/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:karman_app/database/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  await NotificationService.init(navigatorKey);
  tz.initializeTimeZones();

  final databaseService = DatabaseService();
  await databaseService.database; 

  // Initialize controllers
  final taskController = TaskController();
  final habitController = HabitController();

  // Load initial data
  await taskController.loadTasks();
  await habitController.loadHabits();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => taskController),
      ChangeNotifierProvider(create: (context) => habitController),
    ],
    child: KarmanApp(navigatorKey: navigatorKey),
  ));
}

class KarmanApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const KarmanApp({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        brightness: Brightness.dark,
      ),
      home: AppShell(key: AppShell.globalKey),
    );
  }
}
