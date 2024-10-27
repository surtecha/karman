import 'package:karman_app/models/habits/habit_schedule.dart';

class Habit {
  final int? habitId;
  final String habitName;
  final Duration? reminderTime;
  final HabitSchedule schedule;
  int currentStreak;
  int bestStreak;
  bool isCompletedToday;
  DateTime startDate;
  DateTime? lastCompletionDate;

  Habit({
    this.habitId,
    required this.habitName,
    this.reminderTime,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.isCompletedToday = false,
    required this.startDate,
    this.lastCompletionDate,
    this.schedule = const HabitSchedule(),
  });

  Map<String, dynamic> toMap() {
    final map = {
      'habitId': habitId,
      'habitName': habitName,
      'reminderTime': reminderTime?.inMinutes,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'isCompletedToday': isCompletedToday ? 1 : 0,
      'startDate': startDate.toIso8601String(),
      'lastCompletionDate': lastCompletionDate?.toIso8601String(),
    };
    map.addAll(schedule.toMap());
    return map;
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      habitId: map['habitId'],
      habitName: map['habitName'],
      reminderTime: map['reminderTime'] != null
          ? Duration(minutes: map['reminderTime'])
          : null,
      currentStreak: map['currentStreak'],
      bestStreak: map['bestStreak'],
      isCompletedToday: map['isCompletedToday'] == 1,
      startDate: DateTime.parse(map['startDate']),
      lastCompletionDate: map['lastCompletionDate'] != null
          ? DateTime.parse(map['lastCompletionDate'])
          : null,
      schedule: HabitSchedule.fromMap(map),
    );
  }

  Habit copyWith({
    int? habitId,
    String? habitName,
    Duration? reminderTime,
    int? currentStreak,
    int? bestStreak,
    bool? isCompletedToday,
    DateTime? startDate,
    DateTime? lastCompletionDate,
    HabitSchedule? schedule,
  }) {
    return Habit(
      habitId: habitId ?? this.habitId,
      habitName: habitName ?? this.habitName,
      reminderTime: reminderTime ?? this.reminderTime,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      isCompletedToday: isCompletedToday ?? this.isCompletedToday,
      startDate: startDate ?? this.startDate,
      lastCompletionDate: lastCompletionDate ?? this.lastCompletionDate,
      schedule: schedule ?? this.schedule,
    );
  }

  bool shouldCompleteToday() {
    final now = DateTime.now();
    return schedule.isDaySelected(now.weekday);
  }

  bool hasSkippedRequiredDays(DateTime start, DateTime end) {
    DateTime current = start.add(Duration(days: 1));
    while (current.isBefore(end)) {
      if (schedule.isDaySelected(current.weekday)) {
        return true;
      }
      current = current.add(Duration(days: 1));
    }
    return false;
  }

  void resetStreak() {
    currentStreak = 0;
    isCompletedToday = false;
    startDate = DateTime.now();
    lastCompletionDate = null;
  }

  void updateStreak(DateTime completionDate) {
    if (lastCompletionDate == null) {
      currentStreak = 1;
    } else {
      final daysDifference =
          completionDate.difference(lastCompletionDate!).inDays;

      if (daysDifference == 1 ||
          (daysDifference > 1 &&
              !hasSkippedRequiredDays(lastCompletionDate!, completionDate))) {
        currentStreak++;
      } else if (daysDifference > 1 &&
          hasSkippedRequiredDays(lastCompletionDate!, completionDate)) {
        resetStreak();
        currentStreak = 1;
      }
    }

    if (currentStreak > bestStreak) {
      bestStreak = currentStreak;
    }

    lastCompletionDate = completionDate;
    isCompletedToday = true;
  }

  String get formattedReminderTime {
    if (reminderTime == null) return 'No reminder set';
    final hours = reminderTime!.inHours;
    final minutes = reminderTime!.inMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }
}
