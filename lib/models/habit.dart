class Habit {
  final int? id;
  final String name;
  final String? description;
  final DateTime reminder;
  final bool customReminder;
  final Set<int> reminderDays;
  final int currentStreak;
  final int maxStreak;
  final DateTime? lastCompletionDate;
  final DateTime createdAt;
  final int sortOrder;

  Habit({
    this.id,
    required this.name,
    this.description,
    required this.reminder,
    this.customReminder = false,
    this.reminderDays = const {},
    this.currentStreak = 0,
    this.maxStreak = 0,
    this.lastCompletionDate,
    DateTime? createdAt,
    this.sortOrder = 0,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isScheduledForToday {
    if (!customReminder) return true;
    return reminderDays.contains(DateTime.now().weekday);
  }

  bool get isCompletedToday {
    if (lastCompletionDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final completionDay = DateTime(
      lastCompletionDate!.year,
      lastCompletionDate!.month,
      lastCompletionDate!.day,
    );
    return completionDay == today;
  }

  bool get isStreakActive => currentStreak > 0;

  int _getGracePeriod() {
    if (currentStreak >= 30) return 3;
    if (currentStreak >= 7) return 1;
    return 0;
  }

  bool shouldResetStreak() {
    if (lastCompletionDate == null || currentStreak == 0) return false;
    if (isCompletedToday) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastCompletion = DateTime(
      lastCompletionDate!.year,
      lastCompletionDate!.month,
      lastCompletionDate!.day,
    );

    if (customReminder && reminderDays.isNotEmpty) {
      DateTime checkDate = lastCompletion.add(const Duration(days: 1));
      int missedCount = 0;

      while (checkDate.isBefore(today)) {
        if (reminderDays.contains(checkDate.weekday)) {
          missedCount++;
          if (missedCount > _getGracePeriod()) return true;
        }
        checkDate = checkDate.add(const Duration(days: 1));
      }
      return false;
    }

    final daysMissed = today.difference(lastCompletion).inDays - 1;
    return daysMissed > _getGracePeriod();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'reminder': reminder.millisecondsSinceEpoch,
      'custom_reminder': customReminder ? 1 : 0,
      'reminder_days': reminderDays.isEmpty ? null : reminderDays.join(','),
      'current_streak': currentStreak,
      'max_streak': maxStreak,
      'last_completion_date': lastCompletionDate?.millisecondsSinceEpoch,
      'created_at': createdAt.millisecondsSinceEpoch,
      'sort_order': sortOrder,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      reminder: DateTime.fromMillisecondsSinceEpoch(map['reminder']),
      customReminder: map['custom_reminder'] == 1,
      reminderDays: map['reminder_days'] != null
          ? (map['reminder_days'] as String).split(',').map(int.parse).toSet()
          : {},
      currentStreak: map['current_streak'] ?? 0,
      maxStreak: map['max_streak'] ?? 0,
      lastCompletionDate: map['last_completion_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['last_completion_date'])
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      sortOrder: map['sort_order'] ?? 0,
    );
  }

  Habit copyWith({
    int? id,
    String? name,
    String? description,
    DateTime? reminder,
    bool? customReminder,
    Set<int>? reminderDays,
    int? currentStreak,
    int? maxStreak,
    DateTime? lastCompletionDate,
    DateTime? createdAt,
    int? sortOrder,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      reminder: reminder ?? this.reminder,
      customReminder: customReminder ?? this.customReminder,
      reminderDays: reminderDays ?? this.reminderDays,
      currentStreak: currentStreak ?? this.currentStreak,
      maxStreak: maxStreak ?? this.maxStreak,
      lastCompletionDate: lastCompletionDate ?? this.lastCompletionDate,
      createdAt: createdAt ?? this.createdAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
