import 'package:flutter/foundation.dart';
import 'package:karman_app/models/task/task.dart';
import '../../services/task/task_service.dart';

class TaskController extends ChangeNotifier {
  final TaskService _taskService = TaskService();

  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  Future<void> loadTasks() async {
    _tasks = await _taskService.getTasks();
    notifyListeners();
  }

  Future<Task> addTask(Task task) async {
    try {
      final newTask = await _taskService.createTask(task);
      _tasks.add(newTask);
      notifyListeners();
      return newTask;
    } catch (e) {
      print('Error adding task: $e');
      rethrow;
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

  Future<void> clearCompletedTasks() async {
    await _taskService.deleteCompletedTasks();
    _tasks.removeWhere((task) => task.isCompleted);
    notifyListeners();
  }

  List<Task> getCompletedTasks() {
    return _tasks.where((task) => task.isCompleted).toList();
  }

  List<Task> getIncompleteTasks() {
    return _tasks.where((task) => !task.isCompleted).toList();
  }
}
