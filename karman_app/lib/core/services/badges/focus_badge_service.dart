import 'package:karman_app/core/constants/focus_badge_constants.dart';
import 'package:karman_app/core/services/database/database_service.dart';
import 'package:karman_app/core/services/database/focus_db.dart';

class FocusBadgeService {
  final FocusDatabase _focusDatabase = FocusDatabase();

  Future<List<String>> checkNewlyAchievedBadges() async {
    print("FocusBadgeService: Checking for newly achieved badges");
    final database = await DatabaseService().database;
    final achievedBadges = await checkFocusBadges();

    List<String> newlyAchievedBadges = [];

    for (var entry in achievedBadges.entries) {
      if (entry.value) {
        bool isAlreadyAchieved =
            await _focusDatabase.isBadgeAchieved(database, entry.key);
        if (!isAlreadyAchieved) {
          await _focusDatabase.addAchievedBadge(database, entry.key);
          newlyAchievedBadges.add(entry.key);
        }
      }
    }

    print("FocusBadgeService: Newly achieved badges: $newlyAchievedBadges");
    return newlyAchievedBadges;
  }

  Future<Map<String, bool>> checkFocusBadges() async {
    final database = await DatabaseService().database;
    final today = DateTime.now();
    final oneWeekAgo = today.subtract(Duration(days: 7));
    final oneMonthAgo = today.subtract(Duration(days: 30));
    final threeMonthsAgo = today.subtract(Duration(days: 90));

    final todaySessions = await _focusDatabase.getFocusSessionsForDate(
        database, today.toIso8601String().split('T')[0]);
    final weekSessions = await _focusDatabase.getFocusSessionsForDateRange(
        database,
        oneWeekAgo.toIso8601String().split('T')[0],
        today.toIso8601String().split('T')[0]);
    final monthSessions = await _focusDatabase.getFocusSessionsForDateRange(
        database,
        oneMonthAgo.toIso8601String().split('T')[0],
        today.toIso8601String().split('T')[0]);
    final threeMonthSessions =
        await _focusDatabase.getFocusSessionsForDateRange(
            database,
            threeMonthsAgo.toIso8601String().split('T')[0],
            today.toIso8601String().split('T')[0]);

    int todayTotalMinutes = _calculateTotalMinutes(todaySessions);
    int weekTotalMinutes = _calculateTotalMinutes(weekSessions);
    int monthTotalMinutes = _calculateTotalMinutes(monthSessions);
    int threeMonthTotalMinutes = _calculateTotalMinutes(threeMonthSessions);

    Map<String, bool> achievedBadges = {};

    for (var badge in FocusBadgeConstants.focusBadges) {
      bool isAlreadyAchieved =
          await _focusDatabase.isBadgeAchieved(database, badge.name);
      if (isAlreadyAchieved) {
        achievedBadges[badge.name] = true;
      } else {
        bool isNewlyAchieved = await _checkFocusBadge(
          badge,
          database,
          todayTotalMinutes,
          weekTotalMinutes,
          monthTotalMinutes,
          threeMonthTotalMinutes,
        );
        achievedBadges[badge.name] = isNewlyAchieved;
      }
    }

    return achievedBadges;
  }

  Future<bool> _checkFocusBadge(
    FocusBadge badge,
    dynamic database,
    int todayTotalMinutes,
    int weekTotalMinutes,
    int monthTotalMinutes,
    int threeMonthTotalMinutes,
  ) async {
    switch (badge.name) {
      case "First Focus":
        return todayTotalMinutes >= 10;
      case "Half-Hour Hero":
        return todayTotalMinutes >= 30;
      case "Hour Hero":
        return todayTotalMinutes >= 60;
      case "Productivity Pro":
        return todayTotalMinutes >= 90;
      case "Centurion":
        return todayTotalMinutes >= 100;
      case "Two-Hour Triumph":
        return todayTotalMinutes >= 120;
      case "Daily Dynamo":
        return todayTotalMinutes >= 150;
      case "Focus Fanatic":
        return todayTotalMinutes >= 150;
      case "Steady Stream":
        return todayTotalMinutes >= 180;
      case "Weekly Winner":
        return weekTotalMinutes >= 600;
      case "Monthly Marathoner":
        return monthTotalMinutes >= 1200;
      case "Ultimate Timer":
        return threeMonthTotalMinutes >= 5000;
      case "Focus Fiend":
        return await _checkConsecutiveDays(database, 3, 30);
      case "Consistency Champion":
        return await _checkConsecutiveDays(database, 7, 60);
      case "Weekly Warrior":
        return await _checkConsecutiveDays(database, 7, 90);
      case "Monthly Milestone":
        return monthTotalMinutes >= (60 * 30);
      case "Daily Dedication":
        return await _checkConsecutiveDays(database, 5, 60);
      case "Extended Effort":
        return await _checkConsecutiveDays(database, 7, 120);
      case "Focused Finder":
        return await _checkConsecutiveDays(database, 10, 90);
      case "Routine Regulator":
        return await _checkConsecutiveDays(database, 30, 90);
      default:
        return false;
    }
  }

  int _calculateTotalMinutes(List<Map<String, dynamic>> sessions) {
    return sessions.fold(
        0, (sum, session) => sum + (session['duration'] as int) ~/ 60);
  }

  Future<bool> _checkConsecutiveDays(
      dynamic database, int days, int minutes) async {
    final today = DateTime.now();
    for (int i = 0; i < days; i++) {
      final date = today.subtract(Duration(days: i));
      final sessions = await _focusDatabase.getFocusSessionsForDate(
          database, date.toIso8601String().split('T')[0]);
      if (_calculateTotalMinutes(sessions) < minutes) {
        return false;
      }
    }
    return true;
  }
}
