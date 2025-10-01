import '../models/todo.dart';
import 'database_helper.dart';

class TodoRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> insertTodo(Todo todo) async {
    final db = await _databaseHelper.database;
    return await db.insert('todos', todo.toMap());
  }

  Future<List<Todo>> getAllTodos() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: 'is_deleted = ?',
      whereArgs: [0],
      orderBy: 'sort_order ASC',
    );
    return List.generate(maps.length, (i) => Todo.fromMap(maps[i]));
  }

  Future<List<Todo>> getDeletedTodos() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: 'is_deleted = ?',
      whereArgs: [1],
      orderBy: 'id DESC',
    );
    return List.generate(maps.length, (i) => Todo.fromMap(maps[i]));
  }

  Future<List<Todo>> getTodayTodos() async {
    final db = await _databaseHelper.database;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: 'is_deleted = ? AND completed = ? AND ((reminder IS NULL) OR (reminder >= ? AND reminder <= ?))',
      whereArgs: [0, 0, startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch],
      orderBy: 'sort_order ASC',
    );
    return List.generate(maps.length, (i) => Todo.fromMap(maps[i]));
  }

  Future<List<Todo>> getScheduledTodos() async {
    final db = await _databaseHelper.database;
    final now = DateTime.now();
    final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: 'is_deleted = ? AND completed = ? AND reminder IS NOT NULL AND reminder > ?',
      whereArgs: [0, 0, endOfToday.millisecondsSinceEpoch],
      orderBy: 'sort_order ASC',
    );
    return List.generate(maps.length, (i) => Todo.fromMap(maps[i]));
  }

  Future<List<Todo>> getDecideTodos() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: 'is_deleted = ? AND completed = ? AND reminder IS NULL',
      whereArgs: [0, 0],
      orderBy: 'sort_order ASC',
    );
    return List.generate(maps.length, (i) => Todo.fromMap(maps[i]));
  }

  Future<int> updateTodo(Todo todo) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  Future<int> deleteTodo(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> softDeleteTodo(int id) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'todos',
      {'is_deleted': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> restoreTodo(int id) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'todos',
      {'is_deleted': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> toggleTodoCompleted(int id, bool completed) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'todos',
      {'completed': completed ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateTodosOrder(List<Todo> todos) async {
    final db = await _databaseHelper.database;
    final batch = db.batch();

    for (int i = 0; i < todos.length; i++) {
      batch.update(
        'todos',
        {'sort_order': i},
        where: 'id = ?',
        whereArgs: [todos[i].id],
      );
    }

    await batch.commit();
  }
}