import 'package:flutter/foundation.dart';
import 'package:karman_app/models/task/task.dart';
import 'package:karman_app/models/task/task_folder.dart';
import '../../services/task/task_service.dart';

class TaskController extends ChangeNotifier {
  final TaskService _taskService = TaskService();

  List<Task> _tasks = [];
  List<TaskFolder> _folders = [];

  List<Task> get tasks => _tasks;
  List<TaskFolder> get folders => _folders;

  Future<void> loadTasks() async {
    _tasks = await _taskService.getTasks();
    notifyListeners();
  }

  Future<void> loadFolders() async {
    _folders = await _taskService.getFolders();
    notifyListeners();
  }

  List<Task> getTasksForFolder(int folderId) {
    return _tasks.where((task) => task.folderId == folderId).toList();
  }

  Future<Task?> addTask(Task task) async {
    try {
      final id = await _taskService.createTask(task);
      final newTask = Task(
        taskId: id,
        name: task.name,
        note: task.note,
        priority: task.priority,
        dueDate: task.dueDate,
        reminder: task.reminder,
        folderId: task.folderId,
        isCompleted: false,
      );
      _tasks.add(newTask);
      notifyListeners();
      return newTask;
    } catch (e) {
      print('Error adding task: $e');
      return null;
    }
  }

  Future<void> updateTask(Task task) async {
    await _taskService.updateTask(task);
    final index = _tasks.indexWhere((t) => t.taskId == task.taskId);
    if (index != -1) {
      _tasks[index] = task;
      notifyListeners();
    }
  }

  Future<void> deleteTask(int id) async {
    await _taskService.deleteTask(id);
    _tasks.removeWhere((task) => task.taskId == id);
    notifyListeners();
  }

  Future<TaskFolder?> addFolder(TaskFolder folder) async {
    final id = await _taskService.createFolder(folder);
    final newFolder = TaskFolder(folder_id: id, name: folder.name);
    _folders.add(newFolder);
    notifyListeners();
    return newFolder;
  }

  Future<void> updateFolder(TaskFolder folder) async {
    await _taskService.updateFolder(folder);
    final index = _folders.indexWhere((f) => f.folder_id == folder.folder_id);
    if (index != -1) {
      _folders[index] = folder;
      notifyListeners();
    }
  }

  Future<void> deleteFolder(int id) async {
    await _taskService.deleteFolder(id);
    _folders.removeWhere((folder) => folder.folder_id == id);
    _tasks.removeWhere((task) => task.folderId == id);
    notifyListeners();
  }

  TaskFolder? getFolderById(int folderId) {
    try {
      return _folders.firstWhere((folder) => folder.folder_id == folderId);
    } catch (e) {
      return null;
    }
  }
}
