import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:karman_app/database/habit_db.dart';
import 'package:karman_app/database/task_db.dart';
import 'package:karman_app/database/focus_db.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  static const _databaseName = "karman_app.db";
  static const _databaseVersion = 3; // Updated version number

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initializeDatabase();
    return _database!;
  }

  Future<String> get fullPath async {
    final databasesPath = await getDatabasesPath();
    return join(databasesPath, _databaseName);
  }

  Future<Database> _initializeDatabase() async {
    final path = await fullPath;
    var database = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      singleInstance: true,
    );
    return database;
  }

  Future<void> _onCreate(Database db, int version) async {
    await TaskDatabase().createTable(db);
    await HabitDatabase().createTables(db);
    await FocusDatabase().createTable(db);
    await HabitDatabase().createBadgesTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
          'ALTER TABLE ${TaskDatabase().tableName} ADD COLUMN `order` INTEGER NOT NULL DEFAULT 0');

      await db.execute('''
        UPDATE ${TaskDatabase().tableName}
        SET `order` = (
          SELECT COUNT(*)
          FROM ${TaskDatabase().tableName} AS t2
          WHERE t2.priority = ${TaskDatabase().tableName}.priority
            AND t2.is_completed = ${TaskDatabase().tableName}.is_completed
            AND (t2.task_id < ${TaskDatabase().tableName}.task_id OR (t2.task_id = ${TaskDatabase().tableName}.task_id AND t2.name <= ${TaskDatabase().tableName}.name))
        )
      ''');
    }

    if (oldVersion < 3) {
      // Create temporary table with new schema
      await db.execute('''
        CREATE TABLE habits_temp (
          habitId INTEGER PRIMARY KEY AUTOINCREMENT,
          habitName TEXT NOT NULL,
          reminderTime INTEGER,
          currentStreak INTEGER NOT NULL,
          bestStreak INTEGER NOT NULL,
          isCompletedToday INTEGER NOT NULL,
          startDate TEXT NOT NULL,
          lastCompletionDate TEXT,
          selectedDays TEXT NOT NULL DEFAULT '1,2,3,4,5,6,7'
        )
      ''');

      // Copy data from old table to temporary table
      await db.execute('''
        INSERT INTO habits_temp (
          habitId,
          habitName,
          reminderTime,
          currentStreak,
          bestStreak,
          isCompletedToday,
          startDate,
          lastCompletionDate
        )
        SELECT
          habitId,
          habitName,
          reminderTime,
          currentStreak,
          bestStreak,
          isCompletedToday,
          startDate,
          lastCompletionDate
        FROM ${HabitDatabase().tableName}
      ''');

      // Drop the old table
      await db.execute('DROP TABLE ${HabitDatabase().tableName}');

      // Rename the temporary table to the original name
      await db.execute(
          'ALTER TABLE habits_temp RENAME TO ${HabitDatabase().tableName}');
    }
  }

  Future<void> ensureInitialized() async {
    await database;
  }

  Future<void> deleteDatabase() async {
    final path = await fullPath;
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
