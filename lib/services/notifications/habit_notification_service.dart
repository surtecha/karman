import '../../models/habit.dart';
import 'base_notification_service.dart';

class HabitNotificationService {
  static final HabitNotificationService _instance =
      HabitNotificationService._internal();
  factory HabitNotificationService() => _instance;
  HabitNotificationService._internal();

  final BaseNotificationService _base = BaseNotificationService();

  int _getDailyNotificationId(int habitId) => 3000 + habitId;
  int _getWarningNotificationId(int habitId, int level) =>
      4000 + (habitId * 10) + level;

  int _getGracePeriodDays(int currentStreak) {
    if (currentStreak >= 30) return 3;
    if (currentStreak >= 7) return 1;
    return 0;
  }

  Future<void> scheduleHabitNotifications(Habit habit) async {
    if (habit.id == null) return;

    await cancelHabitNotifications(habit.id!);
    await _scheduleDailyReminders(habit);
    if (habit.currentStreak > 0 && !habit.isCompletedToday) {
      await _scheduleStreakWarnings(habit);
    }
  }

  Future<void> _scheduleDailyReminders(Habit habit) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
      final targetDate = today.add(Duration(days: dayOffset));

      if (habit.customReminder &&
          !habit.reminderDays.contains(targetDate.weekday)) {
        continue;
      }

      final reminderTime = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        habit.reminder.hour,
        habit.reminder.minute,
      );

      if (reminderTime.isAfter(now)) {
        await _base.scheduleNotification(
          id: _getDailyNotificationId(habit.id!) + dayOffset,
          title: habit.name,
          body: 'Time to check in',
          scheduledDate: reminderTime,
          channelId: 'habit_reminders',
          payload: 'habit_${habit.id}',
        );
      }
    }
  }

  Future<void> _scheduleStreakWarnings(Habit habit) async {
    if (habit.lastCompletionDate == null) return;

    final gracePeriodDays = _getGracePeriodDays(habit.currentStreak);
    if (gracePeriodDays == 0) return;

    final now = DateTime.now();
    final lastCompletion = DateTime(
      habit.lastCompletionDate!.year,
      habit.lastCompletionDate!.month,
      habit.lastCompletionDate!.day,
    );

    DateTime graceExpiration;
    if (habit.customReminder && habit.reminderDays.isNotEmpty) {
      graceExpiration = _calculateCustomGraceExpiration(
        habit,
        lastCompletion,
        gracePeriodDays,
      );
    } else {
      graceExpiration = lastCompletion.add(Duration(days: gracePeriodDays + 1));
    }

    final warning1 = graceExpiration.subtract(const Duration(hours: 2));
    final warning2 = graceExpiration.subtract(const Duration(minutes: 30));

    if (warning1.isAfter(now)) {
      await _base.scheduleNotification(
        id: _getWarningNotificationId(habit.id!, 1),
        title: habit.name,
        body: '${habit.currentStreak} day streak at risk',
        scheduledDate: warning1,
        channelId: 'habit_reminders',
        payload: 'habit_warning_${habit.id}',
      );
    }

    if (warning2.isAfter(now)) {
      await _base.scheduleNotification(
        id: _getWarningNotificationId(habit.id!, 2),
        title: habit.name,
        body: '${habit.currentStreak} day streak ending soon',
        scheduledDate: warning2,
        channelId: 'habit_reminders',
        payload: 'habit_warning_${habit.id}',
      );
    }

    if (graceExpiration.isAfter(now)) {
      await _base.scheduleNotification(
        id: _getWarningNotificationId(habit.id!, 3),
        title: habit.name,
        body: '${habit.currentStreak} day streak lost',
        scheduledDate: graceExpiration,
        channelId: 'habit_reminders',
        payload: 'habit_lost_${habit.id}',
      );
    }
  }

  DateTime _calculateCustomGraceExpiration(
    Habit habit,
    DateTime lastCompletion,
    int graceDays,
  ) {
    DateTime checkDate = lastCompletion.add(const Duration(days: 1));
    int scheduledDaysMissed = 0;

    while (scheduledDaysMissed <= graceDays) {
      if (habit.reminderDays.contains(checkDate.weekday)) {
        scheduledDaysMissed++;
      }
      if (scheduledDaysMissed > graceDays) break;
      checkDate = checkDate.add(const Duration(days: 1));
    }

    return DateTime(
      checkDate.year,
      checkDate.month,
      checkDate.day,
      habit.reminder.hour,
      habit.reminder.minute,
    );
  }

  Future<void> cancelHabitNotifications(int habitId) async {
    for (int i = 0; i < 7; i++) {
      await _base.cancelNotification(_getDailyNotificationId(habitId) + i);
    }

    for (int i = 1; i <= 3; i++) {
      await _base.cancelNotification(_getWarningNotificationId(habitId, i));
    }
  }

  Future<void> handleHabitCompletion(int habitId) async {
    for (int i = 1; i <= 3; i++) {
      await _base.cancelNotification(_getWarningNotificationId(habitId, i));
    }
  }

  Future<void> handleHabitDeletion(int habitId) async {
    await cancelHabitNotifications(habitId);
  }
}
