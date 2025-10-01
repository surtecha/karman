import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'karman.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: _onOpen,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE todos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        reminder INTEGER,
        completed INTEGER NOT NULL DEFAULT 0,
        sort_order INTEGER NOT NULL DEFAULT 0,
        is_deleted INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> _onOpen(Database db) async {
    final columns = await db.rawQuery('PRAGMA table_info(todos)');
    final columnNames = columns.map((col) => col['name'] as String).toList();
    if (!columnNames.contains('sort_order')) {
      await db.execute('ALTER TABLE todos ADD COLUMN sort_order INTEGER NOT NULL DEFAULT 0');
    }
    if (!columnNames.contains('is_deleted')) {
      await db.execute('ALTER TABLE todos ADD COLUMN is_deleted INTEGER NOT NULL DEFAULT 0');
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
    }
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}