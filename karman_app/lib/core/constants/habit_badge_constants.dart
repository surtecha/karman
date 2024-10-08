class HabitBadge {
  final String name;
  final String description;

  const HabitBadge({required this.name, required this.description});
}

class HabitBadgeConstants {
  static const List<HabitBadge> habitBadges = [
    HabitBadge(
      name: "Habit Starter",
      description: "Create your first habit",
    ),
    HabitBadge(
      name: "Consistency Beginner",
      description: "Complete a habit for 3 days in a row",
    ),
    HabitBadge(
      name: "Week Warrior",
      description: "Complete a habit for 7 days in a row",
    ),
    HabitBadge(
      name: "Fortnight Finisher",
      description: "Complete a habit for 14 days in a row",
    ),
    HabitBadge(
      name: "Monthly Master",
      description: "Complete a habit for 30 days in a row",
    ),
    HabitBadge(
      name: "Quarterly Queen",
      description: "Complete a habit for 90 days in a row",
    ),
    HabitBadge(
      name: "Habit Centurion",
      description: "Complete a habit for 100 days in a row",
    ),
    HabitBadge(
      name: "Yearly Yield",
      description: "Complete a habit for 365 days in a row",
    ),
    HabitBadge(
      name: "Habit Collector",
      description: "Create 5 different habits",
    ),
    HabitBadge(
      name: "Habit Enthusiast",
      description: "Create 10 different habits",
    ),
    HabitBadge(
      name: "Perfect Week",
      description: "Complete all habits for 7 days in a row",
    ),
    HabitBadge(
      name: "Perfect Month",
      description: "Complete all habits for 30 days in a row",
    ),
  ];
}
