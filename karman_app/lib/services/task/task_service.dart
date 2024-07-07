import 'package:karman_app/database/database_service.dart';
import 'package:karman_app/database/task_db.dart';
import 'package:karman_app/models/task/task.dart';
import 'package:karman_app/models/task/task_folder.dart';

class TaskService {
  final DatabaseService _databaseService = DatabaseService();
  final TaskDatabase _taskDatabase = TaskDatabase();

  // Task operations
  Future<int> createTask(Task task) async {
    final db = await _databaseService.database;
    return await _taskDatabase.createTask(db, task.toMap());
  }

  Future<List<Task>> getTasks() async {
    final db = await _databaseService.database;
    final tasksData = await _taskDatabase.getTasks(db);
    return tasksData.map((taskData) => Task.fromMap(taskData)).toList();
  }

  Future<int> updateTask(Task task) async {
    final db = await _databaseService.database;
    return await _taskDatabase.updateTask(db, task.toMap());
  }

  Future<int> deleteTask(int id) async {
    final db = await _databaseService.database;
    return await _taskDatabase.deleteTask(db, id);
  }

  // Task folder operations
  Future<int> createFolder(TaskFolder folder) async {
    final db = await _databaseService.database;
    return await _taskDatabase.createFolder(db, folder.toMap());
  }

  Future<List<TaskFolder>> getFolders() async {
    final db = await _databaseService.database;
    final foldersData = await _taskDatabase.getFolders(db);
    return foldersData.map((folderData) => TaskFolder.fromMap(folderData)).toList();
  }

  Future<int> updateFolder(TaskFolder folder) async {
    final db = await _databaseService.database;
    return await _taskDatabase.updateFolder(db, folder.toMap());
  }

  Future<int> deleteFolder(int id) async {
    final db = await _databaseService.database;
    return await _taskDatabase.deleteFolder(db, id);
  }
}