class HabitLog {
  final int? id;
  final String? log;
  final bool completedForToday;
  final int habitId;
  final DateTime date;

  HabitLog({
    this.id,
    this.log,
    required this.completedForToday,
    required this.habitId,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'log': log,
      'completedForToday': completedForToday ? 1 : 0,
      'habitId': habitId,
      'date': date.toIso8601String(),
    };
  }

  factory HabitLog.fromMap(Map<String, dynamic> map) {
    return HabitLog(
      id: map['id'],
      log: map['log'],
      completedForToday: map['completedForToday'] == 1,
      habitId: map['habitId'],
      date: DateTime.parse(map['date']),
    );
  }

  HabitLog copyWith({
    int? id,
    String? log,
    bool? completedForToday,
    int? habitId,
    DateTime? date,
  }) {
    return HabitLog(
      id: id ?? this.id,
      log: log ?? this.log,
      completedForToday: completedForToday ?? this.completedForToday,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
    );
  }

  @override
  String toString() {
    return 'HabitLog(id: $id, log: $log, completedForToday: $completedForToday, habitId: $habitId, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HabitLog &&
        other.id == id &&
        other.log == log &&
        other.completedForToday == completedForToday &&
        other.habitId == habitId &&
        other.date == date;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        log.hashCode ^
        completedForToday.hashCode ^
        habitId.hashCode ^
        date.hashCode;
  }
}
