import 'package:sqflite/sqflite.dart';

class FocusDatabase {
  final String tableName = 'focus_sessions';
  final String badgesTableName = 'focus_badges';

  Future<void> createTable(Database database) async {
    await database.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        duration INTEGER NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    await database.execute('''
      CREATE TABLE IF NOT EXISTS $badgesTableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        badge_name TEXT NOT NULL,
        achieved_date TEXT NOT NULL
      )
    ''');
  }

  Future<int> addFocusSession(Database db, int duration, String date) async {
    return await db.insert(tableName, {
      'duration': duration,
      'date': date,
    });
  }

  Future<List<Map<String, dynamic>>> getFocusSessionsForDate(
      Database db, String date) async {
    return await db.query(
      tableName,
      where: 'date = ?',
      whereArgs: [date],
    );
  }

  Future<List<Map<String, dynamic>>> getFocusSessionsForDateRange(
      Database db, String startDate, String endDate) async {
    return await db.query(
      tableName,
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate, endDate],
    );
  }

  Future<void> addAchievedBadge(Database db, String badgeName) async {
    final date = DateTime.now().toIso8601String();
    await db.insert(badgesTableName, {
      'badge_name': badgeName,
      'achieved_date': date,
    });
  }

  Future<bool> isBadgeAchieved(Database db, String badgeName) async {
    final result = await db.query(
      badgesTableName,
      where: 'badge_name = ?',
      whereArgs: [badgeName],
      limit: 1,
    );
    return result.isNotEmpty;
  }
}
