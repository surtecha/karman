class Habit {
  final int? habitId;
  final String habitName;
  final Duration? reminderTime;
  int currentStreak;
  int bestStreak;
  bool isCompletedToday;

  Habit({
    this.habitId,
    required this.habitName,
    this.reminderTime,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.isCompletedToday = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'habitId': habitId,
      'habitName': habitName,
      'reminderTime': reminderTime?.inMinutes,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'isCompletedToday': isCompletedToday ? 1 : 0,
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
    );
  }

  Habit copyWith({
    int? habitId,
    String? habitName,
    Duration? reminderTime,
    int? currentStreak,
    int? bestStreak,
    bool? isCompletedToday,
  }) {
    return Habit(
      habitId: habitId ?? this.habitId,
      habitName: habitName ?? this.habitName,
      reminderTime: reminderTime ?? this.reminderTime,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      isCompletedToday: isCompletedToday ?? this.isCompletedToday,
    );
  }

  void resetStreak() {
    currentStreak = 0;
    isCompletedToday = false;
  }

  void incrementStreak() {
    currentStreak++;
    if (currentStreak > bestStreak) {
      bestStreak = currentStreak;
    }
    isCompletedToday = true;
  }

  String get formattedReminderTime {
    if (reminderTime == null) return 'No reminder set';
    final hours = reminderTime!.inHours;
    final minutes = reminderTime!.inMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }
}
