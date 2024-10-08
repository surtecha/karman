import 'dart:async';

import 'package:flutter/material.dart';
import 'package:karman_app/core/constants/focus_notification_constants.dart';
import 'package:karman_app/core/services/badges/focus_badge_service.dart';
import 'package:karman_app/core/services/feature_services/focus_service.dart';
import 'package:karman_app/core/services/feature_services/timer_service.dart';
import 'package:karman_app/core/services/manager/sound_manager.dart';
import 'package:karman_app/core/services/notifications/focus_notification_service.dart';

class FocusController extends ChangeNotifier {
  final SoundManager _soundManager = SoundManager();
  final TimerService _timerService = TimerService();
  final FocusService _focusService = FocusService();
  final FocusBadgeService _achievementService = FocusBadgeService();
  final StreamController<List<String>> _achievementStreamController =
      StreamController<List<String>>.broadcast();

  static const int _minTimerValue = 1;

  int _timerValue = _minTimerValue;
  bool _isTimerRunning = false;
  late DateTime _endTime;
  Timer? _timer;
  int _remainingSeconds = 60;
  int _totalSeconds = 60;

  int get timerValue => _timerValue;
  bool get isTimerRunning => _isTimerRunning;
  int get remainingSeconds => _remainingSeconds;
  int get totalSeconds => _totalSeconds;
  SoundManager get soundManager => _soundManager;
  Stream<List<String>> get achievementStream =>
      _achievementStreamController.stream;

  FocusController() {
    _loadTimerState();
  }

  Future<void> _loadTimerState() async {
    final timerState = await _timerService.getTimerState();
    _timerValue = timerState['timerValue'];
    _isTimerRunning = timerState['isTimerRunning'];
    _remainingSeconds = timerState['remainingSeconds'];
    _totalSeconds = timerState['totalSeconds'];
    notifyListeners();
    if (_isTimerRunning) {
      _startTimer();
      _soundManager.playSelectedSound();
    }
  }

  void onSliderValueChanged(int value) {
    _timerValue = value;
    _remainingSeconds = value * 60;
    _totalSeconds = _remainingSeconds;
    _saveTimerState();
    notifyListeners();
  }

  void toggleTimer() {
    _isTimerRunning = !_isTimerRunning;
    if (_isTimerRunning) {
      _startTimer();
      _soundManager.playSelectedSound();
    } else {
      _stopTimer();
    }
    _saveTimerState();
    notifyListeners();
  }

  void _startTimer() {
    _endTime = DateTime.now().add(Duration(seconds: _remainingSeconds));
    _updateTimer();
    _timer = Timer.periodic(Duration(seconds: 1), (_) => _updateTimer());
  }

  void _updateTimer() {
    final now = DateTime.now();
    if (now.isBefore(_endTime)) {
      _remainingSeconds = _endTime.difference(now).inSeconds;
      _saveTimerState();
      notifyListeners();
    } else {
      _stopTimer();
    }
  }

  void _stopTimer() {
    _timer?.cancel();
    _isTimerRunning = false;
    _soundManager.stopBackgroundSound();

    if (_remainingSeconds <= 0) {
      _showFocusEndNotification();
      _recordFocusSession();
    } else {
      _resetTimer();
    }
    _saveTimerState();
    notifyListeners();
  }

  void _resetTimer() {
    _timerValue = _minTimerValue;
    _remainingSeconds = _timerValue * 60;
    _totalSeconds = _remainingSeconds;
  }

  Future<void> _saveTimerState() async {
    await _timerService.saveTimerState(
      timerValue: _timerValue,
      isTimerRunning: _isTimerRunning,
      remainingSeconds: _remainingSeconds,
      totalSeconds: _totalSeconds,
    );
  }

  void _recordFocusSession() async {
    final duration = _totalSeconds - _remainingSeconds;
    await _focusService.addFocusSession(duration);

    List<String> newlyAchievedBadges =
        await _achievementService.checkNewlyAchievedBadges();

    _resetTimer();
    _saveTimerState();
    notifyListeners();

    if (newlyAchievedBadges.isNotEmpty) {
      _achievementStreamController.add(newlyAchievedBadges);
    }
  }

  void _showFocusEndNotification() {
    Future.delayed(Duration(seconds: 1), () {
      FocusNotificationService.showFocusEndNotification(
        title: FocusConstants.endNotificationTitle,
        body: FocusConstants.getRandomEndNotificationBody(),
      );
    });
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  double get progress {
    if (_totalSeconds == 0) return 0;
    return 1 - (_remainingSeconds / _totalSeconds);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _soundManager.dispose();
    _achievementStreamController.close();
    super.dispose();
  }
}
