class Habit {
  final int? id;
  final String name;
  final bool status;
  final DateTime startDate;
  final DateTime? endDate;
  final int currentStreak;
  final int longestStreak;

  Habit({
    this.id,
    required this.name,
    required this.status,
    required this.startDate,
    this.endDate,
    required this.currentStreak,
    required this.longestStreak,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'status': status ? 1 : 0,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'],
      name: map['name'],
      status: map['status'] == 1,
      startDate: DateTime.parse(map['start_date']),
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date']) : null,
      currentStreak: map['current_streak'],
      longestStreak: map['longest_streak'],
    );
  }
}
