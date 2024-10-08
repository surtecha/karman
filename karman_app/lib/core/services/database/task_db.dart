import 'package:sqflite/sqflite.dart';

class TaskDatabase {
  final String tableName = 'tasks';

  Future<void> createTable(Database database) async {
    await database.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        task_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        note TEXT,
        priority INTEGER NOT NULL,
        due_date TEXT,
        reminder TEXT,
        is_completed INTEGER NOT NULL DEFAULT 0,
        `order` INTEGER NOT NULL
      )
    ''');
  }

  // CRUD operations for tasks
  Future<int> createTask(Database db, Map<String, dynamic> task) async {
    return await db.insert(tableName, task);
  }

  Future<List<Map<String, dynamic>>> getTasks(Database db) async {
    return await db.query(tableName, orderBy: '`order` ASC');
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

  Future<int> deleteCompletedTasks(Database db) async {
    return await db.delete(
      tableName,
      where: 'is_completed = ?',
      whereArgs: [1],
    );
  }

  Future<Map<String, dynamic>?> getTaskById(Database db, int id) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'task_id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<int> getMaxOrder(Database db, int priority) async {
    final result = await db.rawQuery('''
      SELECT MAX(`order`) as max_order 
      FROM $tableName 
      WHERE priority = ? AND is_completed = 0
    ''', [priority]);
    return (result.first['max_order'] as int?) ?? 0;
  }

  Future<void> updateTaskOrders(
      Database db, List<Map<String, dynamic>> updates) async {
    await db.transaction((txn) async {
      for (var update in updates) {
        await txn.update(
          tableName,
          {'order': update['new_order']},
          where: 'task_id = ?',
          whereArgs: [update['task_id']],
        );
      }
    });
  }
}
