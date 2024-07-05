import 'package:flutter/cupertino.dart';
import 'package:isar/isar.dart';
import 'package:karman_app/models/app_settings.dart';
import 'package:karman_app/models/habit.dart';
import 'package:path_provider/path_provider.dart';

class HabitDatabase extends ChangeNotifier {
  static late Isar isar;

  /* 
  SETUP 
  */

  // Initialize the Isar instance
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [HabitSchema, AppSettingsSchema],
      directory: dir.path,
    );
  }

  // Save first date of app startup (for heatmap)
  Future<void> saveFirstLaunchDate() async {
    final existingSettings = await isar.appSettings.where().findFirst();
    if (existingSettings == null) {
      final settings = AppSettings()..firstLaunchDate = DateTime.now();
      await isar.writeTxn(() => isar.appSettings.put(settings));
    }
  }

  // Get the first date of app startup (for heatmap)
  Future<DateTime?> getFirstLaunchDate() async {
    final settings = await isar.appSettings.where().findFirst();
    return settings?.firstLaunchDate;
  }

  /*
  CRUD operations for Habits
  */

  // List of all habits
  final List<Habit> currentHabits = [];

  // Create a new habit
  Future<void> addHabit(String habbitName) async {
    // create new habit
    final newHabit = Habit()..name = habbitName;

    // save to db
    await isar.writeTxn(() => isar.habits.put(newHabit));

    // re-read from db
    readHabits();
  }

  // Read all habits
  Future<void> readHabits() async {
    // fetch all habits from db
    final fetchedHabits = await isar.habits.where().findAll();

    // give to currentHabbits
    currentHabits.clear();
    currentHabits.addAll(fetchedHabits);

    // update UI
    notifyListeners();
  }

  // Update if a habit is completed for the day
  Future<void> updateHabitCompletion(int id, bool isCompleted) async {
    // find the specific habit
    final habit = await isar.habits.get(id);

    // update completion status
    if (habit != null) {
      await isar.writeTxn(() async {
        // if habit completed, add to completed days
        if (isCompleted && !habit.completedDays.contains(DateTime.now())) {
          final today = DateTime.now();

          // add to completed days
          habit.completedDays.add(
            DateTime(
              today.year,
              today.month,
              today.day,
            ),
          );
        }
        // if habit not completed, remove from completed days
        else {
          // remove from completed days if not marked as completed
          habit.completedDays.removeWhere(
            (date) =>
                date.year == DateTime.now().year &&
                date.month == DateTime.now().month &&
                date.day == DateTime.now().day,
          );
        }
        // save updated habits
        await isar.habits.put(habit);
      });
    }

    // re-read from db
    readHabits();
  }

  // Update habit name
  Future<void> updateHabitName(int id, String newName) async {
    // find the specific habit
    final habit = await isar.habits.get(id);

    // update habit name
    if (habit != null) {
      await isar.writeTxn(() async {
        habit.name = newName;
        await isar.habits.put(habit);
      });
    }

    // re-read from db
    readHabits();
  }

  // Delete a habit
  Future<void> deleteHabit(int id) async {
    // delete habit
    await isar.habits.delete(id);

    // re-read from db
    readHabits();
  }
}
