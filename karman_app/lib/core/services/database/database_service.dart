import 'package:karman_app/core/services/database/focus_db.dart';
import 'package:karman_app/core/services/database/habit_db.dart';
import 'package:karman_app/core/services/database/task_db.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  static const _databaseName = "karman_app.db";
  static const _databaseVersion = 2;

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
