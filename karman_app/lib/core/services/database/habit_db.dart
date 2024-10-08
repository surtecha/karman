import 'package:sqflite/sqflite.dart';

class HabitDatabase {
  final String tableName = 'habits';
  final String logTableName = 'habit_logs';

  Future<void> createTables(Database database) async {
    await database.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        habitId INTEGER PRIMARY KEY AUTOINCREMENT,
        habitName TEXT NOT NULL,
        reminderTime INTEGER,
        currentStreak INTEGER NOT NULL,
        bestStreak INTEGER NOT NULL,
        isCompletedToday INTEGER NOT NULL,
        startDate TEXT NOT NULL,
        lastCompletionDate TEXT
      )
    ''');

    await database.execute('''
      CREATE TABLE IF NOT EXISTS $logTableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habitId INTEGER NOT NULL,
        date TEXT NOT NULL,
        completedForToday INTEGER NOT NULL,
        log TEXT,
        FOREIGN KEY (habitId) REFERENCES $tableName (habitId)
      )
    ''');
  }

  Future<int> createHabit(Database db, Map<String, dynamic> habit) async {
    return await db.insert(tableName, habit);
  }

  Future<List<Map<String, dynamic>>> getHabits(Database db) async {
    return await db.query(tableName);
  }

  Future<Map<String, dynamic>?> getHabit(Database db, int habitId) async {
    final habits = await db.query(
      tableName,
      where: 'habitId = ?',
      whereArgs: [habitId],
      limit: 1,
    );
    return habits.isNotEmpty ? habits.first : null;
  }

  Future<int> updateHabit(Database db, Map<String, dynamic> habit) async {
    return await db.update(
      tableName,
      habit,
      where: 'habitId = ?',
      whereArgs: [habit['habitId']],
    );
  }

  Future<int> deleteHabit(Database db, int id) async {
    return await db.delete(
      tableName,
      where: 'habitId = ?',
      whereArgs: [id],
    );
  }

  Future<int> createHabitLog(Database db, Map<String, dynamic> log) async {
    return await db.insert(logTableName, log);
  }

  Future<List<Map<String, dynamic>>> getHabitLogs(
    Database db,
    int habitId,
  ) async {
    return await db.query(
      logTableName,
      where: 'habitId = ?',
      whereArgs: [habitId],
      orderBy: 'date DESC',
    );
  }

  Future<int> deleteHabitLogs(Database db, int habitId) async {
    return await db.delete(
      logTableName,
      where: 'habitId = ?',
      whereArgs: [habitId],
    );
  }

  Future<Map<String, dynamic>?> getLatestHabitLog(
    Database db,
    int habitId,
  ) async {
    final logs = await db.query(
      logTableName,
      where: 'habitId = ?',
      whereArgs: [habitId],
      orderBy: 'date DESC',
      limit: 1,
    );
    return logs.isNotEmpty ? logs.first : null;
  }

  Future<List<Map<String, dynamic>>> getHabitLogsForDate(
    Database db,
    int habitId,
    String date,
  ) async {
    return await db.query(
      logTableName,
      where: 'habitId = ? AND date = ?',
      whereArgs: [habitId, date],
    );
  }

  Future<int> resetAllHabitsCompletionStatus(Database db) async {
    return await db.update(
      tableName,
      {'isCompletedToday': 0},
    );
  }

  Future<void> createBadgesTable(Database database) async {
    await database.execute('''
    CREATE TABLE IF NOT EXISTS habit_badges (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      badge_name TEXT NOT NULL,
      achieved_date TEXT NOT NULL
    )
  ''');
  }

  Future<void> addAchievedBadge(Database db, String badgeName) async {
    final date = DateTime.now().toIso8601String();
    await db.insert('habit_badges', {
      'badge_name': badgeName,
      'achieved_date': date,
    });
  }

  Future<bool> isBadgeAchieved(Database db, String badgeName) async {
    final result = await db.query(
      'habit_badges',
      where: 'badge_name = ?',
      whereArgs: [badgeName],
      limit: 1,
    );
    return result.isNotEmpty;
  }
}
