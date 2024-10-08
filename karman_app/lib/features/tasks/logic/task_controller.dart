import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:karman_app/core/services/feature_services/task_service.dart';
import 'package:karman_app/core/services/notifications/task_notification_service.dart';
import 'package:karman_app/features/tasks/data/task.dart';

class TaskController extends ChangeNotifier {
  final TaskService _taskService = TaskService();

  List<Task> _tasks = [];
  final Map<int, Timer> _completionTimers = {};
  final Map<int, bool> _pendingCompletions = {};
  final Map<int, Timer> _updateTimers = {};

  List<Task> get tasks => _tasks;

  Future<void> loadTasks() async {
    _tasks = await _taskService.getTasks();
    _scheduleAllUpdates();
    notifyListeners();
  }

  Future<Task> addTask(Task task) async {
    try {
      final highestOrder = _tasks
          .where((t) => t.priority == task.priority && !t.isCompleted)
          .fold(0, (max, t) => t.order > max ? t.order : max);

      final newTask = task.copyWith(order: highestOrder + 1);

      final createdTask = await _taskService.createTask(newTask);
      _tasks.add(createdTask);
      _scheduleTaskUpdates(createdTask);
      await TaskNotificationService.scheduleNotification(createdTask);
      notifyListeners();
      return createdTask;
    } catch (e) {
      if (kDebugMode) {
        print('Error adding task: $e');
      }
      rethrow;
    }
  }

  Future<Task> updateTask(Task task) async {
    await _taskService.updateTask(task);
    final index = _tasks.indexWhere((t) => t.taskId == task.taskId);
    if (index != -1) {
      _tasks[index] = task;
      _scheduleTaskUpdates(task);
      await TaskNotificationService.updateNotification(task);
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
      _completionTimers[taskId] = Timer(Duration(seconds: 1), () async {
        final updatedTask = task.copyWith(isCompleted: true);
        await updateTask(updatedTask);
        await TaskNotificationService.cancelNotification(taskId);
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
    _updateTimers[id]?.cancel();
    _updateTimers.remove(id);
    await TaskNotificationService.cancelNotification(id);
    notifyListeners();
  }

  Future<void> clearCompletedTasks() async {
    await _taskService.deleteCompletedTasks();
    _tasks.removeWhere((task) {
      if (task.isCompleted) {
        _updateTimers[task.taskId]?.cancel();
        _updateTimers.remove(task.taskId);
        TaskNotificationService.cancelNotification(task.taskId!);
        return true;
      }
      return false;
    });
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
      if (kDebugMode) {
        print('Error fetching task: $e');
      }
      return null;
    }
  }

  void scheduleUpdate(int taskId, DateTime updateTime) {
    _updateTimers[taskId]?.cancel();

    final now = DateTime.now();
    final duration = updateTime.difference(now);

    if (duration.isNegative) {
      notifyListeners();
    } else {
      _updateTimers[taskId] = Timer(duration, () {
        notifyListeners();
        _updateTimers.remove(taskId);
      });
    }
  }

  void _scheduleTaskUpdates(Task task) {
    if (task.dueDate != null) {
      scheduleUpdate(task.taskId!, task.dueDate!);
    }
    if (task.reminder != null) {
      scheduleUpdate(task.taskId!, task.reminder!);
    }
  }

  void _scheduleAllUpdates() {
    for (var task in _tasks) {
      _scheduleTaskUpdates(task);
    }
  }

  Future<void> reorderTasks(int priority, Task movedTask, int newIndex) async {
    final priorityTasks = _tasks
        .where((task) => task.priority == priority && !task.isCompleted)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    final oldIndex =
        priorityTasks.indexWhere((task) => task.taskId == movedTask.taskId);

    if (oldIndex == -1 || oldIndex == newIndex) return;

    // Remove the task from its old position
    priorityTasks.removeAt(oldIndex);

    // Insert the task at its new position
    priorityTasks.insert(newIndex, movedTask);

    // Update the order of all tasks in this priority
    for (int i = 0; i < priorityTasks.length; i++) {
      final updatedTask = priorityTasks[i].copyWith(order: i);
      await _taskService.updateTask(updatedTask);
      final index = _tasks.indexWhere((t) => t.taskId == updatedTask.taskId);
      if (index != -1) {
        _tasks[index] = updatedTask;
      }
    }

    notifyListeners();
  }

  @override
  void dispose() {
    for (var timer in _completionTimers.values) {
      timer.cancel();
    }
    for (var timer in _updateTimers.values) {
      timer.cancel();
    }
    super.dispose();
  }
}
