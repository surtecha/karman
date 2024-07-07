import 'package:karman_app/database/habit_db.dart';
import 'package:karman_app/database/task_db.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initialize();
    return _database!;
  }

  Future<String> get fullPath async {
    const databaseName = 'karman.db';
    final databasesPath = await getDatabasesPath();
    return join(databasesPath, databaseName);
  }

  Future<Database> _initialize() async {
    final path = await fullPath;
    var database = await openDatabase(
      path,
      version: 1,
      onCreate: createDatabase,
      singleInstance: true,
    );
    return database;
  }

  Future<void> createDatabase(Database database, int version) async {
    await TaskDatabase().createTable(database);
    await HabitDatabase().createTable(database);
  }
}
