import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class TimerService {
  static const String _timerValueKey = 'timerValue';
  static const String _isTimerRunningKey = 'isTimerRunning';
  static const String _remainingSecondsKey = 'remainingSeconds';
  static const String _totalSecondsKey = 'totalSeconds';
  static const String _startTimeKey = 'startTime';

  Future<void> saveTimerState({
    required int timerValue,
    required bool isTimerRunning,
    required int remainingSeconds,
    required int totalSeconds,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_timerValueKey, timerValue);
    await prefs.setBool(_isTimerRunningKey, isTimerRunning);
    await prefs.setInt(_remainingSecondsKey, remainingSeconds);
    await prefs.setInt(_totalSecondsKey, totalSeconds);
    if (isTimerRunning) {
      await prefs.setInt(_startTimeKey, DateTime.now().millisecondsSinceEpoch);
    } else {
      await prefs.remove(_startTimeKey);
    }
  }

  Future<Map<String, dynamic>> getTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    final timerValue = prefs.getInt(_timerValueKey) ?? 5;
    final isTimerRunning = prefs.getBool(_isTimerRunningKey) ?? false;
    final remainingSeconds = prefs.getInt(_remainingSecondsKey) ?? 300;
    final totalSeconds = prefs.getInt(_totalSecondsKey) ?? 300;
    final startTime = prefs.getInt(_startTimeKey);

    if (isTimerRunning && startTime != null) {
      final elapsedSeconds = (DateTime.now().millisecondsSinceEpoch - startTime) ~/ 1000;
      final adjustedRemainingSeconds = remainingSeconds - elapsedSeconds;
      return {
        'timerValue': timerValue,
        'isTimerRunning': adjustedRemainingSeconds > 0,
        'remainingSeconds': adjustedRemainingSeconds > 0 ? adjustedRemainingSeconds : 0,
        'totalSeconds': totalSeconds,
      };
    }

    return {
      'timerValue': timerValue,
      'isTimerRunning': isTimerRunning,
      'remainingSeconds': remainingSeconds,
      'totalSeconds': totalSeconds,
    };
  }

  Future<void> clearTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_timerValueKey);
    await prefs.remove(_isTimerRunningKey);
    await prefs.remove(_remainingSecondsKey);
    await prefs.remove(_totalSecondsKey);
    await prefs.remove(_startTimeKey);
  }
}