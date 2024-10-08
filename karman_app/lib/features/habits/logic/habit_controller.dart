import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:karman_app/core/services/badges/habit_badge_service.dart';
import 'package:karman_app/core/services/feature_services/habit_service.dart';
import 'package:karman_app/core/services/notifications/notification_service.dart';
import 'package:karman_app/features/habits/data/habit.dart';
import 'package:karman_app/features/habits/data/habit_log.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HabitController extends ChangeNotifier {
  final HabitService _habitService = HabitService();
  final HabitBadgeService _habitBadgeService = HabitBadgeService();
  List<Habit> _habits = [];
  final Map<int, List<HabitLog>> _habitLogs = {};

  final StreamController<List<String>> _achievementStreamController =
      StreamController<List<String>>.broadcast();

  List<Habit> get habits => _habits;
  Map<int, List<HabitLog>> get habitLogs => _habitLogs;
  Stream<List<String>> get achievementStream =>
      _achievementStreamController.stream;

  Future<void> loadHabits() async {
    await checkAndResetStreaks();
    _habits = await _habitService.getHabits();
    for (var habit in _habits) {
      await loadHabitLogs(habit.habitId!);
    }
    await scheduleStreakReminders();
    notifyListeners();
  }

  Future<void> loadHabitLogs(int habitId) async {
    _habitLogs[habitId] = await _habitService.getHabitLogs(habitId);
    notifyListeners();
  }

  Future<void> addHabit(Habit habit) async {
    final id = await _habitService.createHabit(habit);
    final newHabit = habit.copyWith(habitId: id);
    _habits.add(newHabit);
    _scheduleReminder(newHabit);

    List<String> newlyAchievedBadges =
        await _habitBadgeService.checkNewlyAchievedBadges(_habits);
    if (newlyAchievedBadges.isNotEmpty) {
      _achievementStreamController.add(newlyAchievedBadges);
    }

    await scheduleStreakReminders();
    notifyListeners();
  }

  Future<void> updateHabit(Habit habit) async {
    await _habitService.updateHabit(habit);
    final index = _habits.indexWhere((h) => h.habitId == habit.habitId);
    if (index != -1) {
      _habits[index] = habit;
      _scheduleReminder(habit);
      await scheduleStreakReminders();
      notifyListeners();
    }
  }

  Future<void> deleteHabit(int id) async {
    await _habitService.deleteHabit(id);
    _habits.removeWhere((habit) => habit.habitId == id);
    _habitLogs.remove(id);
    NotificationService.cancelNotification(id);
    await NotificationService.cancelNotification(
        id + 10000); // Cancel streak reminder
    notifyListeners();
  }

  Future<void> completeHabitForToday(Habit habit, String? log) async {
    await _habitService.completeHabitForToday(habit, log);
    final updatedHabit = await _habitService.getHabit(habit.habitId!);
    if (updatedHabit != null) {
      final index = _habits.indexWhere((h) => h.habitId == habit.habitId);
      if (index != -1) {
        _habits[index] = updatedHabit;
      }
    }
    await loadHabitLogs(habit.habitId!);

    List<String> newlyAchievedBadges =
        await _habitBadgeService.checkNewlyAchievedBadges(_habits);
    if (newlyAchievedBadges.isNotEmpty) {
      _achievementStreamController.add(newlyAchievedBadges);
    }

    await NotificationService.cancelNotification(habit.habitId! + 10000);
    notifyListeners();
  }

  Future<void> checkAndResetStreaks() async {
    final now = DateTime.now();
    final lastResetDate = await _getLastResetDate();
    if (lastResetDate == null || !_isSameDay(now, lastResetDate)) {
      await _habitService.resetCompletionStatusForNewDay();
      await _setLastResetDate(now);
    }
  }

  Future<DateTime?> _getLastResetDate() async {
    final prefs = await SharedPreferences.getInstance();
    final lastResetTimestamp = prefs.getInt('last_reset_timestamp');
    return lastResetTimestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(lastResetTimestamp)
        : null;
  }

  Future<void> _setLastResetDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_reset_timestamp', date.millisecondsSinceEpoch);
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Future<void> scheduleReminders() async {
    for (var habit in _habits) {
      _scheduleReminder(habit);
    }
  }

  Future<void> _scheduleReminder(Habit habit) async {
    if (habit.reminderTime != null && habit.habitId != null) {
      final now = DateTime.now();
      var scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        habit.reminderTime!.inHours,
        habit.reminderTime!.inMinutes % 60,
      );

      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(Duration(days: 1));
      }

      await NotificationService.scheduleNotification(
        id: habit.habitId!,
        title: 'Habit Reminder',
        body: habit.habitName,
        scheduledDate: scheduledTime,
        payload: 'habit_${habit.habitId}',
      );
    }
  }

  Future<void> scheduleStreakReminders() async {
    final now = DateTime.now();
    final reminderTime =
        DateTime(now.year, now.month, now.day, 21, 0); // 9:00 PM

    var adjustedReminderTime = reminderTime;
    if (reminderTime.isBefore(now)) {
      adjustedReminderTime = reminderTime.add(Duration(days: 1));
    }

    for (var habit in _habits) {
      if (!habit.isCompletedToday && habit.currentStreak > 0) {
        await NotificationService.scheduleStreakReminder(
          id: habit.habitId!,
          habitName: habit.habitName,
          currentStreak: habit.currentStreak,
          scheduledDate: adjustedReminderTime,
        );
      } else {
        await NotificationService.cancelNotification(habit.habitId! + 10000);
      }
    }
  }

  @override
  void dispose() {
    _achievementStreamController.close();
    super.dispose();
  }
}
