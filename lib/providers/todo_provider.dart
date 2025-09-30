import 'dart:async';
import 'package:flutter/cupertino.dart';
import '../database/todo_repository.dart';
import '../models/todo.dart';

class TodoProvider extends ChangeNotifier {
  final TodoRepository _repository = TodoRepository();
  List<Todo> _todos = [];
  bool _isLoading = false;
  int _selectedIndex = 0;
  final Map<int, Timer> _completionTimers = {};

  List<Todo> get todos => _todos;
  bool get isLoading => _isLoading;
  int get selectedIndex => _selectedIndex;

  List<Todo> get todayTodos => _todos.where((todo) {
    if ((todo.completed && !todo.pendingCompletion) || todo.reminder == null) return false;
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final reminderDate = DateTime(todo.reminder!.year, todo.reminder!.month, todo.reminder!.day);
    return reminderDate.isBefore(tomorrow);
  }).toList()..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  List<Todo> get scheduledTodos => _todos.where((todo) {
    if ((todo.completed && !todo.pendingCompletion) || todo.reminder == null) return false;
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final reminderDate = DateTime(todo.reminder!.year, todo.reminder!.month, todo.reminder!.day);
    return !reminderDate.isBefore(tomorrow);
  }).toList()..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  List<Todo> get decideTodos => _todos.where((todo) =>
  !(todo.completed && !todo.pendingCompletion) && todo.reminder == null
  ).toList()..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  List<Todo> get completedTodos => _todos.where((todo) =>
  todo.completed && !todo.pendingCompletion
  ).toList()..sort((a, b) => b.sortOrder.compareTo(a.sortOrder));

  List<Todo> get currentTodos {
    switch (_selectedIndex) {
      case 0: return todayTodos;
      case 1: return scheduledTodos;
      case 2: return decideTodos;
      default: return [];
    }
  }

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  Future<void> loadTodos() async {
    _isLoading = true;
    notifyListeners();
    try {
      _todos = await _repository.getAllTodos();
    } catch (e) {
      debugPrint('Error loading todos: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTodo(Todo todo) async {
    try {
      final maxOrder = _todos.isEmpty ? 0 : _todos.map((t) => t.sortOrder).reduce((a, b) => a > b ? a : b);
      final todoWithOrder = todo.copyWith(sortOrder: maxOrder + 1);
      final id = await _repository.insertTodo(todoWithOrder);
      _todos.add(todoWithOrder.copyWith(id: id));
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding todo: $e');
    }
  }

  Future<void> updateTodoDirectly(Todo todo) async {
    try {
      await _repository.updateTodo(todo);
      final index = _todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        _todos[index] = todo;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating todo: $e');
    }
  }

  Future<void> updateTodo(Todo todo) async {
    final index = _todos.indexWhere((t) => t.id == todo.id);
    if (index == -1) return;

    _completionTimers[todo.id!]?.cancel();
    _todos[index] = todo;
    notifyListeners();

    _completionTimers[todo.id!] = Timer(
        todo.completed ? const Duration(seconds: 2) : const Duration(milliseconds: 100),
            () async {
          await _repository.updateTodo(todo);
          _completionTimers.remove(todo.id!);
        }
    );
  }

  Future<void> toggleTodo(Todo todo) async {
    final isCompleting = !todo.isVisuallyCompleted;

    if (isCompleting) {
      _completionTimers[todo.id!]?.cancel();
      final pendingTodo = todo.copyWith(pendingCompletion: true);
      final index = _todos.indexWhere((t) => t.id == todo.id);
      _todos[index] = pendingTodo;
      notifyListeners();

      _completionTimers[todo.id!] = Timer(const Duration(seconds: 2), () async {
        final completedTodo = pendingTodo.copyWith(completed: true, pendingCompletion: false);
        final currentIndex = _todos.indexWhere((t) => t.id == todo.id);
        _todos[currentIndex] = completedTodo;
        await _repository.updateTodo(completedTodo);
        _completionTimers.remove(todo.id!);
        notifyListeners();
      });
    } else {
      _completionTimers[todo.id!]?.cancel();
      _completionTimers.remove(todo.id!);
      final uncompletedTodo = todo.copyWith(completed: false, pendingCompletion: false);
      await updateTodo(uncompletedTodo);
    }
  }

  Future<void> deleteTodo(Todo todo) async {
    try {
      _completionTimers[todo.id!]?.cancel();
      _completionTimers.remove(todo.id!);
      await _repository.deleteTodo(todo.id!);
      _todos.removeWhere((t) => t.id == todo.id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting todo: $e');
    }
  }

  Future<void> reorderTodos(int oldIndex, int newIndex) async {
    final currentList = List<Todo>.from(currentTodos);
    final item = currentList.removeAt(oldIndex);
    currentList.insert(newIndex, item);

    for (int i = 0; i < currentList.length; i++) {
      final todo = currentList[i];
      final mainIndex = _todos.indexWhere((t) => t.id == todo.id);
      if (mainIndex != -1) {
        _todos[mainIndex] = todo.copyWith(sortOrder: i);
      }
    }

    try {
      await _repository.updateTodosOrder(currentList);
      notifyListeners();
    } catch (e) {
      debugPrint('Error reordering todos: $e');
    }
  }

  @override
  void dispose() {
    _completionTimers.values.forEach((timer) => timer.cancel());
    super.dispose();
  }
}