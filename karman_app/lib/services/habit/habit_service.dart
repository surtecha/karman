import 'package:karman_app/database/database_service.dart';
import 'package:karman_app/database/habit_db.dart';
import 'package:karman_app/models/habits/habit.dart';
import 'package:karman_app/models/habits/habit_log.dart';

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
    return habitsData.map((habitData) => Habit.fromMap(habitData)).toList();
  }

  Future<Habit?> getHabit(int habitId) async {
    final db = await _databaseService.database;
    final habitData = await _habitDatabase.getHabit(db, habitId);
    return habitData != null ? Habit.fromMap(habitData) : null;
  }

  Future<int> updateHabit(Habit habit) async {
    final db = await _databaseService.database;
    return await _habitDatabase.updateHabit(db, habit.toMap());
  }

  Future<int> deleteHabit(int id) async {
    final db = await _databaseService.database;
    await _habitDatabase.deleteHabitLogs(db, id);
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

  Future<void> resetStreaksIfNeeded() async {
    final db = await _databaseService.database;
    final habits = await getHabits();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (var habit in habits) {
      final latestLog =
          await _habitDatabase.getLatestHabitLog(db, habit.habitId!);
      if (latestLog != null) {
        final latestLogDate = DateTime.parse(latestLog['date']);
        final logDay = DateTime(
            latestLogDate.year, latestLogDate.month, latestLogDate.day);

        if (today.isAfter(logDay)) {
          // It's a new day, reset isCompletedToday
          habit.isCompletedToday = false;

          if (today.difference(logDay).inDays > 1) {
            // More than one day has passed, reset streak
            habit.resetStreak();
          }

          await updateHabit(habit);
        }
      }
    }
  }

  Future<void> completeHabitForToday(Habit habit, String? log) async {
    final db = await _databaseService.database;
    final today = DateTime.now();
    final todayString = today.toIso8601String().split('T')[0];

    // Check if the habit has already been completed today
    final todayLogs = await _habitDatabase.getHabitLogsForDate(
        db, habit.habitId!, todayString);
    if (todayLogs.isNotEmpty && todayLogs.first['completedForToday'] == 1) {
      // Habit already completed today, no need to update
      return;
    }

    // Create new log for today
    final todayLog = HabitLog(
      habitId: habit.habitId!,
      completedForToday: true,
      date: today,
      log: log,
    );
    await createHabitLog(todayLog);

    // Check if the streak should be incremented
    final yesterday = today.subtract(Duration(days: 1));
    final yesterdayString = yesterday.toIso8601String().split('T')[0];
    final yesterdayLogs = await _habitDatabase.getHabitLogsForDate(
        db, habit.habitId!, yesterdayString);

    if (yesterdayLogs.isNotEmpty &&
        yesterdayLogs.first['completedForToday'] == 1) {
      // Habit was completed yesterday, increment streak
      habit.incrementStreak();
    } else {
      // Habit was not completed yesterday, reset streak to 1
      habit.currentStreak = 1;
    }

    habit.isCompletedToday = true;
    await updateHabit(habit);
  }

  Future<bool> isHabitCompletedToday(int habitId) async {
    final db = await _databaseService.database;
    final today = DateTime.now().toIso8601String().split('T')[0];
    final logs = await _habitDatabase.getHabitLogsForDate(db, habitId, today);
    return logs.isNotEmpty && logs.first['completedForToday'] == 1;
  }
}
