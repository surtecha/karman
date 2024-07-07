class HabitLog {
  final int? id;
  final int habitId;
  final DateTime date;
  final bool status;

  HabitLog({
    this.id,
    required this.habitId,
    required this.date,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habit_id': habitId,
      'date': date.toIso8601String(),
      'status': status ? 1 : 0,
    };
  }

  factory HabitLog.fromMap(Map<String, dynamic> map) {
    return HabitLog(
      id: map['id'],
      habitId: map['habit_id'],
      date: DateTime.parse(map['date']),
      status: map['status'] == 1,
    );
  }
}
