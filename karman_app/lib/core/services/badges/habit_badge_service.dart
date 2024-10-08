import 'package:karman_app/core/constants/habit_badge_constants.dart';
import 'package:karman_app/core/services/database/database_service.dart';
import 'package:karman_app/core/services/database/habit_db.dart';
import 'package:karman_app/features/habits/data/habit.dart';

class HabitBadgeService {
  final HabitDatabase _habitDatabase = HabitDatabase();

  Future<List<String>> checkNewlyAchievedBadges(List<Habit> habits) async {
    final database = await DatabaseService().database;
    final achievedBadges = await checkHabitBadges(habits);

    List<String> newlyAchievedBadges = [];

    for (var entry in achievedBadges.entries) {
      if (entry.value) {
        bool isAlreadyAchieved =
            await _habitDatabase.isBadgeAchieved(database, entry.key);
        if (!isAlreadyAchieved) {
          await _habitDatabase.addAchievedBadge(database, entry.key);
          newlyAchievedBadges.add(entry.key);
        }
      }
    }

    return newlyAchievedBadges;
  }

  Future<Map<String, bool>> checkHabitBadges(List<Habit> habits) async {
    Map<String, bool> achievedBadges = {};

    for (var badge in HabitBadgeConstants.habitBadges) {
      achievedBadges[badge.name] = await _checkHabitBadge(badge, habits);
    }

    return achievedBadges;
  }

  Future<bool> _checkHabitBadge(HabitBadge badge, List<Habit> habits) async {
    switch (badge.name) {
      case "Habit Starter":
        return habits.isNotEmpty;
      case "Consistency Beginner":
        return habits.any((habit) => habit.currentStreak >= 3);
      case "Week Warrior":
        return habits.any((habit) => habit.currentStreak >= 7);
      case "Fortnight Finisher":
        return habits.any((habit) => habit.currentStreak >= 14);
      case "Monthly Master":
        return habits.any((habit) => habit.currentStreak >= 30);
      case "Quarterly Queen":
        return habits.any((habit) => habit.currentStreak >= 90);
      case "Habit Centurion":
        return habits.any((habit) => habit.currentStreak >= 100);
      case "Yearly Yield":
        return habits.any((habit) => habit.currentStreak >= 365);
      case "Habit Collector":
        return habits.length >= 5;
      case "Habit Enthusiast":
        return habits.length >= 10;
      case "Perfect Week":
        return _checkPerfectStreak(habits, 7);
      case "Perfect Month":
        return _checkPerfectStreak(habits, 30);
      default:
        return false;
    }
  }

  bool _checkPerfectStreak(List<Habit> habits, int days) {
    if (habits.isEmpty) return false;
    return habits.every((habit) => habit.currentStreak >= days);
  }
}
