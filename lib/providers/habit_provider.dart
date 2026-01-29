import 'package:flutter/cupertino.dart';
import '../database/habit_repository.dart';
import '../models/habit.dart';
import '../services/notifications/habit_notification_service.dart';

class HabitProvider extends ChangeNotifier {
  final HabitRepository _repository = HabitRepository();
  final HabitNotificationService _notificationService =
      HabitNotificationService();
  List<Habit> _habits = [];
  bool _isLoading = false;
  int _selectedIndex = 0;
  bool _isSelectionMode = false;
  final Set<int> _selectedHabitIds = {};

  List<Habit> get habits => _habits;
  bool get isLoading => _isLoading;
  int get selectedIndex => _selectedIndex;
  bool get isSelectionMode => _isSelectionMode;
  Set<int> get selectedHabitIds => _selectedHabitIds;

  List<Habit> get todayHabits =>
      _habits
          .where(
            (habit) => habit.isScheduledForToday && !habit.isCompletedToday,
          )
          .toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  List<Habit> get scheduledHabits =>
      _habits
          .where(
            (habit) => !habit.isScheduledForToday || habit.isCompletedToday,
          )
          .toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  List<Habit> get currentHabits =>
      _selectedIndex == 0 ? todayHabits : scheduledHabits;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void toggleSelectionMode() {
    _isSelectionMode = !_isSelectionMode;
    if (!_isSelectionMode) _selectedHabitIds.clear();
    notifyListeners();
  }

  void toggleHabitSelection(int habitId) {
    if (_selectedHabitIds.contains(habitId)) {
      _selectedHabitIds.remove(habitId);
    } else {
      _selectedHabitIds.add(habitId);
    }
    notifyListeners();
  }

  bool isHabitSelected(int habitId) => _selectedHabitIds.contains(habitId);

  Future<void> deleteSelectedHabits() async {
    try {
      for (final habitId in _selectedHabitIds) {
        await _repository.deleteHabit(habitId);
      }
      await loadHabits();
      _selectedHabitIds.clear();
      _isSelectionMode = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting selected habits: $e');
    }
  }

  Future<void> loadHabits() async {
    _isLoading = true;
    notifyListeners();

    try {
      _habits = await _repository.getAllHabits();

      for (final habit in _habits) {
        if (habit.shouldResetStreak()) {
          await _repository.resetStreakIfNeeded(habit.id!);
        }
      }

      _habits = await _repository.getAllHabits();

      for (final habit in _habits) {
        await _notificationService.scheduleHabitNotifications(habit);
      }
    } catch (e) {
      debugPrint('Error loading habits: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addHabit(Habit habit) async {
    try {
      final maxOrder =
          _habits.isEmpty
              ? 0
              : _habits.map((h) => h.sortOrder).reduce((a, b) => a > b ? a : b);
      final habitWithOrder = habit.copyWith(sortOrder: maxOrder + 1);
      final id = await _repository.insertHabit(habitWithOrder);
      final newHabit = habitWithOrder.copyWith(id: id);
      _habits.add(newHabit);
      await _notificationService.scheduleHabitNotifications(newHabit);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding habit: $e');
    }
  }

  Future<void> updateHabit(Habit habit) async {
    try {
      await _repository.updateHabit(habit);
      final index = _habits.indexWhere((h) => h.id == habit.id);
      if (index != -1) {
        _habits[index] = habit;
        await _notificationService.scheduleHabitNotifications(habit);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating habit: $e');
    }
  }

  Future<void> deleteHabit(int habitId) async {
    try {
      await _notificationService.handleHabitDeletion(habitId);
      await _repository.deleteHabit(habitId);
      _habits.removeWhere((h) => h.id == habitId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting habit: $e');
    }
  }

  Future<void> completeHabit(int habitId) async {
    try {
      await _notificationService.handleHabitCompletion(habitId);
      await _repository.completeHabit(habitId);
      await loadHabits();
    } catch (e) {
      debugPrint('Error completing habit: $e');
    }
  }

  Future<void> reorderHabits(int oldIndex, int newIndex) async {
    final currentList = List<Habit>.from(currentHabits);
    final item = currentList.removeAt(oldIndex);
    currentList.insert(newIndex, item);

    for (int i = 0; i < currentList.length; i++) {
      final habit = currentList[i];
      final mainIndex = _habits.indexWhere((h) => h.id == habit.id);
      if (mainIndex != -1) {
        _habits[mainIndex] = habit.copyWith(sortOrder: i);
      }
    }

    try {
      await _repository.updateHabitsOrder(currentList);
      notifyListeners();
    } catch (e) {
      debugPrint('Error reordering habits: $e');
    }
  }
}
