import 'package:karman_app/database/database_service.dart';
import 'package:karman_app/database/task_db.dart';
import 'package:karman_app/models/task/task.dart';

class TaskService {
  final DatabaseService _databaseService = DatabaseService();
  final TaskDatabase _taskDatabase = TaskDatabase();

  Future<Task> createTask(Task task) async {
    final db = await _databaseService.database;
    final id = await _taskDatabase.createTask(db, task.toMap());
    return task.copyWith(taskId: id);
  }

  Future<List<Task>> getTasks() async {
    final db = await _databaseService.database;
    final tasksData = await _taskDatabase.getTasks(db);
    return tasksData.map((taskData) => Task.fromMap(taskData)).toList();
  }

  Future<Task> updateTask(Task task) async {
    final db = await _databaseService.database;
    await _taskDatabase.updateTask(db, task.toMap());
    return task;
  }

  Future<void> deleteTask(int id) async {
    final db = await _databaseService.database;
    await _taskDatabase.deleteTask(db, id);
  }

  Future<void> deleteCompletedTasks() async {
    final db = await _databaseService.database;
    await _taskDatabase.deleteCompletedTasks(db);
  }

  Future<Task?> getTaskById(int id) async {
    final db = await _databaseService.database;
    final taskData = await _taskDatabase.getTaskById(db, id);
    return taskData != null ? Task.fromMap(taskData) : null;
  }
}
