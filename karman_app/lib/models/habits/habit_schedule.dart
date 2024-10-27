class HabitSchedule {
  final String selectedDays; // "1,2,3,4,5" for Monday through Friday

  const HabitSchedule({
    this.selectedDays = "1,2,3,4,5,6,7", // Default to all days
  });

  Map<String, dynamic> toMap() {
    return {
      'selectedDays': selectedDays,
    };
  }

  factory HabitSchedule.fromMap(Map<String, dynamic> map) {
    return HabitSchedule(
      selectedDays: map['selectedDays'] ?? "1,2,3,4,5,6,7",
    );
  }

  bool isDaySelected(int weekday) {
    final days = selectedDays.split(',').map(int.parse).toList();
    return days.contains(weekday);
  }

  List<int> get selectedDaysList {
    return selectedDays.split(',').map(int.parse).toList();
  }

  HabitSchedule copyWith({
    String? selectedDays,
  }) {
    return HabitSchedule(
      selectedDays: selectedDays ?? this.selectedDays,
    );
  }

  static String daysToString(List<int> days) {
    return days.join(',');
  }
}
