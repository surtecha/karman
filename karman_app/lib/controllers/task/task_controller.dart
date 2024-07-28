import 'package:flutter/foundation.dart';
import 'package:karman_app/models/task/task.dart';
import '../../services/task/task_service.dart';
import 'dart:async';

class TaskController extends ChangeNotifier {
  final TaskService _taskService = TaskService();

  List<Task> _tasks = [];
  final Map<int, Timer> _completionTimers = {};
  final Map<int, bool> _pendingCompletions = {};

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

  Future<Task> updateTask(Task task) async {
    await _taskService.updateTask(task);
    final index = _tasks.indexWhere((t) => t.taskId == task.taskId);
    if (index != -1) {
      _tasks[index] = task;
      notifyListeners();
    }
    return task;
  }

  void toggleTaskCompletion(Task task) {
    final taskId = task.taskId!;
    if (_pendingCompletions[taskId] == true) {
      _completionTimers[taskId]?.cancel();
      _completionTimers.remove(taskId);
      _pendingCompletions[taskId] = false;
    } else if (!task.isCompleted) {
      _pendingCompletions[taskId] = true;
      _completionTimers[taskId] = Timer(Duration(seconds: 3), () {
        final updatedTask = task.copyWith(isCompleted: true);
        updateTask(updatedTask);
        _completionTimers.remove(taskId);
        _pendingCompletions.remove(taskId);
        notifyListeners();
      });
    } else {
      final updatedTask = task.copyWith(isCompleted: false);
      updateTask(updatedTask);
    }
    notifyListeners();
  }

  bool isTaskPendingCompletion(int taskId) {
    return _pendingCompletions[taskId] == true;
  }

  Future<void> deleteTask(int id) async {
    await _taskService.deleteTask(id);
    _tasks.removeWhere((task) => task.taskId == id);
    _completionTimers[id]?.cancel();
    _completionTimers.remove(id);
    _pendingCompletions.remove(id);
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

  Future<Task?> getTaskById(int taskId) async {
    try {
      return await _taskService.getTaskById(taskId);
    } catch (e) {
      print('Error fetching task: $e');
      return null;
    }
  }

  @override
  void dispose() {
    for (var timer in _completionTimers.values) {
      timer.cancel();
    }
    super.dispose();
  }
}
