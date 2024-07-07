import 'package:sqflite/sqflite.dart';

class TaskDatabase {
  final String tableName = 'tasks';
  final String folderTableName = 'task_folders';

  Future<void> createTable(Database database) async {
    await database.execute('''
      CREATE TABLE IF NOT EXISTS $folderTableName (
        folder_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon INTEGER NOT NULL
      )
    ''');

    await database.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        task_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        note TEXT,
        priority INTEGER NOT NULL,
        due_date TEXT,
        reminder TEXT,
        folder_id INTEGER,
        is_completed INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (folder_id) REFERENCES $folderTableName (folder_id)
      )
    ''');
  }

  // CRUD operations for tasks
  Future<int> createTask(Database db, Map<String, dynamic> task) async {
    return await db.insert(tableName, task);
  }

  Future<List<Map<String, dynamic>>> getTasks(Database db) async {
    return await db.query(tableName);
  }

  Future<int> updateTask(Database db, Map<String, dynamic> task) async {
    return await db.update(
      tableName,
      task,
      where: 'task_id = ?',
      whereArgs: [task['task_id']],
    );
  }

  Future<int> deleteTask(Database db, int id) async {
    return await db.delete(
      tableName,
      where: 'task_id = ?',
      whereArgs: [id],
    );
  }

  // CRUD operations for task folders
  Future<int> createFolder(Database db, Map<String, dynamic> folder) async {
    return await db.insert(folderTableName, folder);
  }

  Future<List<Map<String, dynamic>>> getFolders(Database db) async {
    return await db.query(folderTableName);
  }

  Future<int> updateFolder(Database db, Map<String, dynamic> folder) async {
    return await db.update(
      folderTableName,
      folder,
      where: 'folder_id = ?',
      whereArgs: [folder['folder_id']],
    );
  }

  Future<int> deleteFolder(Database db, int id) async {
    return await db.delete(
      folderTableName,
      where: 'folder_id = ?',
      whereArgs: [id],
    );
  }
}
