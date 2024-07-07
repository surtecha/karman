import 'package:flutter/foundation.dart';
import 'package:karman_app/models/habits/habit.dart';
import 'package:karman_app/models/habits/habit_log.dart';
import '../../services/habit/habit_service.dart';

class HabitController extends ChangeNotifier {
  final HabitService _habitService = HabitService();

  List<Habit> _habits = [];
  Map<int, List<HabitLog>> _habitLogs = {};

  List<Habit> get habits => _habits;
  Map<int, List<HabitLog>> get habitLogs => _habitLogs;

  Future<void> loadHabits() async {
    _habits = await _habitService.getHabits();
    notifyListeners();
  }

  Future<void> loadHabitLogs(int habitId) async {
    _habitLogs[habitId] = await _habitService.getHabitLogs(habitId);
    notifyListeners();
  }

  Future<void> addHabit(Habit habit) async {
    final id = await _habitService.createHabit(habit);
    final newHabit = Habit(
      id: id,
      name: habit.name,
      status: habit.status,
      startDate: habit.startDate,
      endDate: habit.endDate,
      currentStreak: habit.currentStreak,
      longestStreak: habit.longestStreak,
    );
    _habits.add(newHabit);
    notifyListeners();
  }

  Future<void> updateHabit(Habit habit) async {
    await _habitService.updateHabit(habit);
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      _habits[index] = habit;
      notifyListeners();
    }
  }

  Future<void> deleteHabit(int id) async {
    await _habitService.deleteHabit(id);
    _habits.removeWhere((habit) => habit.id == id);
    _habitLogs.remove(id);
    notifyListeners();
  }

  Future<void> addHabitLog(HabitLog log) async {
    final id = await _habitService.createHabitLog(log);
    final newLog = HabitLog(
      id: id,
      habitId: log.habitId,
      date: log.date,
      status: log.status,
    );
    _habitLogs[log.habitId] ??= [];
    _habitLogs[log.habitId]!.add(newLog);
    notifyListeners();
  }

  Future<void> updateHabitLog(HabitLog log) async {
    await _habitService.updateHabitLog(log);
    final logs = _habitLogs[log.habitId];
    if (logs != null) {
      final index = logs.indexWhere((l) => l.id == log.id);
      if (index != -1) {
        logs[index] = log;
        notifyListeners();
      }
    }
  }

  Future<void> deleteHabitLog(int habitId, int logId) async {
    await _habitService.deleteHabitLog(logId);
    _habitLogs[habitId]?.removeWhere((log) => log.id == logId);
    notifyListeners();
  }
}
