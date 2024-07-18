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
  await NotificationService.init();
  tz.initializeTimeZones();

  final databaseService = DatabaseService();
  await databaseService.database; // This initializes the database

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
    child: KarmanApp(),
  ));
}

class KarmanApp extends StatelessWidget {
  const KarmanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        brightness: Brightness.dark,
      ),
      home: AppShell(),
    );
  }
}
