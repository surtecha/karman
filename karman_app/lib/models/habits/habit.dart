class Habit {
  final int? habitId;
  final String habitName;
  final Duration? reminderTime;
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
  });

  Map<String, dynamic> toMap() {
    return {
      'habitId': habitId,
      'habitName': habitName,
      'reminderTime': reminderTime?.inMinutes,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'isCompletedToday': isCompletedToday ? 1 : 0,
      'startDate': startDate.toIso8601String(),
      'lastCompletionDate': lastCompletionDate?.toIso8601String(),
    };
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
    );
  }

  void resetStreak() {
    currentStreak = 0;
    isCompletedToday = false;
    startDate = DateTime.now();
    lastCompletionDate = null;
  }

  void updateStreak(DateTime completionDate) {
    if (lastCompletionDate == null ||
        completionDate.difference(lastCompletionDate!).inDays == 1) {
      currentStreak++;
      if (currentStreak > bestStreak) {
        bestStreak = currentStreak;
      }
    } else if (completionDate.difference(lastCompletionDate!).inDays > 1) {
      resetStreak();
      currentStreak = 1;
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
