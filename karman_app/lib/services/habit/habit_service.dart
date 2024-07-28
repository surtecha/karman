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
    final habits = await getHabits();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (var habit in habits) {
      if (habit.lastCompletionDate != null) {
        final lastCompletionDay = DateTime(
          habit.lastCompletionDate!.year,
          habit.lastCompletionDate!.month,
          habit.lastCompletionDate!.day,
        );

        if (today.isAfter(lastCompletionDay)) {
          habit.isCompletedToday = false;

          if (today.difference(lastCompletionDay).inDays > 1) {
            habit.resetStreak();
          }

          await updateHabit(habit);
        }
      }
    }
  }

  Future<void> completeHabitForToday(Habit habit, String? log) async {
    final db = await _databaseService.database;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final todayLogs = await _habitDatabase.getHabitLogsForDate(
      db,
      habit.habitId!,
      today.toIso8601String(),
    );

    if (todayLogs.isNotEmpty && todayLogs.first['completedForToday'] == 1) {
      return;
    }

    final todayLog = HabitLog(
      habitId: habit.habitId!,
      completedForToday: true,
      date: now,
      log: log,
    );
    await createHabitLog(todayLog);

    habit.updateStreak(today);

    await updateHabit(habit);
  }

  Future<bool> isHabitCompletedToday(int habitId) async {
    final db = await _databaseService.database;
    final today = DateTime.now().toIso8601String().split('T')[0];
    final logs = await _habitDatabase.getHabitLogsForDate(db, habitId, today);
    return logs.isNotEmpty && logs.first['completedForToday'] == 1;
  }
}
