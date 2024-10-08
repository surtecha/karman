import 'package:karman_app/core/services/database/database_service.dart';
import 'package:karman_app/core/services/database/habit_db.dart';
import 'package:karman_app/features/habits/data/habit.dart';
import 'package:karman_app/features/habits/data/habit_log.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HabitService {
  final DatabaseService _databaseService = DatabaseService();
  final HabitDatabase _habitDatabase = HabitDatabase();

  Future<int> createHabit(Habit habit) async {
    final db = await _databaseService.database;
    return await _habitDatabase.createHabit(db, habit.toMap());
  }

  Future<List<Habit>> getHabits() async {
    final db = await _databaseService.database;
    final habitsData = await _habitDatabase.getHabits(db);
    final habits =
        habitsData.map((habitData) => Habit.fromMap(habitData)).toList();

    final prefs = await SharedPreferences.getInstance();
    for (var habit in habits) {
      final isCompleted =
          prefs.getBool('habit_${habit.habitId}_completed') ?? false;
      habit.isCompletedToday = isCompleted;
    }

    return habits;
  }

  Future<Habit?> getHabit(int habitId) async {
    final db = await _databaseService.database;
    final habitData = await _habitDatabase.getHabit(db, habitId);
    if (habitData != null) {
      final habit = Habit.fromMap(habitData);

      final prefs = await SharedPreferences.getInstance();
      habit.isCompletedToday =
          prefs.getBool('habit_${habit.habitId}_completed') ?? false;

      return habit;
    }
    return null;
  }

  Future<int> updateHabit(Habit habit) async {
    final db = await _databaseService.database;
    return await _habitDatabase.updateHabit(db, habit.toMap());
  }

  Future<int> deleteHabit(int id) async {
    final db = await _databaseService.database;
    await _habitDatabase.deleteHabitLogs(db, id);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('habit_${id}_completed');

    return await _habitDatabase.deleteHabit(db, id);
  }

  Future<int> createHabitLog(HabitLog log) async {
    final db = await _databaseService.database;
    return await _habitDatabase.createHabitLog(db, log.toMap());
  }

  Future<List<HabitLog>> getHabitLogs(int habitId) async {
    final db = await _databaseService.database;
    final logsData = await _habitDatabase.getHabitLogs(db, habitId);
    return logsData.map((logData) => HabitLog.fromMap(logData)).toList();
  }

  Future<void> completeHabitForToday(Habit habit, String? log) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final todayLog = HabitLog(
      habitId: habit.habitId!,
      completedForToday: true,
      date: now,
      log: log,
    );
    await createHabitLog(todayLog);

    habit.updateStreak(today);
    habit.isCompletedToday = true;

    await updateHabit(habit);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('habit_${habit.habitId}_completed', true);
  }

  Future<bool> isHabitCompletedToday(int habitId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('habit_${habitId}_completed') ?? false;
  }

  Future<void> resetCompletionStatusForNewDay() async {
    final prefs = await SharedPreferences.getInstance();
    final habits = await getHabits();

    for (var habit in habits) {
      await prefs.setBool('habit_${habit.habitId}_completed', false);
      habit.isCompletedToday = false;
      await updateHabit(habit);
    }
  }
}
