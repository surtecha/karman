import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:karman_app/app_state.dart';
import 'package:karman_app/core/constants/pomodoro_constants.dart';
import 'package:karman_app/core/services/feature_services/focus_service.dart';
import 'package:karman_app/core/services/manager/sound_manager.dart';
import 'package:karman_app/core/services/notifications/pomodoro_notification_service.dart';
import 'package:provider/provider.dart';

class PomodoroController extends ChangeNotifier {
  final FocusService _focusService = FocusService();
  final BuildContext _context;
  final SoundManager soundManager = SoundManager();

  Timer? _timer;
  bool _isRunning = false;
  bool _isFocusSession = true;
  int _currentSession = 0;
  int _focusDuration = 25;
  int _breakDuration = 5;
  int _totalSessions = 4;
  Duration _currentDuration = Duration(minutes: 25);
  bool _isSoundMenuOpen = false;
  String _currentQuote = '';
  DateTime? _sessionStartTime;

  bool get isRunning => _isRunning;
  bool get isFocusSession => _isFocusSession;
  int get currentSession => _currentSession;
  int get focusDuration => _focusDuration;
  int get breakDuration => _breakDuration;
  int get totalSessions => _totalSessions;
  Duration get currentDuration => _currentDuration;
  bool get isSoundMenuOpen => _isSoundMenuOpen;
  String get currentQuote => _currentQuote;

  List<int> focusDurations = [15, 20, 25, 30, 35];
  List<int> breakDurations = [1, 5, 10, 15];
  List<int> sessionOptions = [3, 4, 5, 6];

  PomodoroController(this._context) {
    _updateQuote();
  }

  String get formattedTime {
    int minutes = _currentDuration.inMinutes;
    int seconds = _currentDuration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get progress {
    int totalSeconds =
        _isFocusSession ? _focusDuration * 60 : _breakDuration * 60;
    int elapsedSeconds = totalSeconds - _currentDuration.inSeconds;
    return elapsedSeconds / totalSeconds;
  }

  void toggleTimer() {
    if (_isRunning) {
      _showStopConfirmationDialog();
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    _isRunning = true;
    _sessionStartTime = DateTime.now();
    _timer = Timer.periodic(Duration(seconds: 1), _updateTimer);
    Provider.of<AppState>(_context, listen: false).setPomodoroActive(true);
    if (_isFocusSession) {
      soundManager.playSelectedSound();
      _updateQuote();
    }
    _showNotification();
    notifyListeners();
  }

  void stopTimer({bool countSession = false}) {
    _isRunning = false;
    _timer?.cancel();
    Provider.of<AppState>(_context, listen: false).setPomodoroActive(false);
    soundManager.stopBackgroundSound();
    PomodoroNotificationService.cancelNotification();

    if (countSession && _isFocusSession && _sessionStartTime != null) {
      int sessionDuration =
          DateTime.now().difference(_sessionStartTime!).inSeconds;
      _focusService.addFocusSession(sessionDuration);
    }

    _resetTimer();
    notifyListeners();
  }

  void _showStopConfirmationDialog() {
    showCupertinoDialog(
      context: _context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text('Stop Pomodoro Session?'),
        content: Text(
            'Your time will not be counted towards badges if you stop now.'),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.of(context).pop();
              stopTimer(countSession: false);
            },
            child: Text('Stop'),
          ),
        ],
      ),
    );
  }

  void _updateTimer(Timer timer) {
    if (_currentDuration.inSeconds > 0) {
      _currentDuration = _currentDuration - Duration(seconds: 1);
    } else {
      if (_isFocusSession) {
        _focusService.addFocusSession(_focusDuration * 60);
      }
      _switchSession();
    }
    notifyListeners();
  }

  void _switchSession() {
    if (_isFocusSession) {
      _currentSession++;
      if (_currentSession < _totalSessions) {
        _isFocusSession = false;
        _currentDuration = Duration(minutes: _breakDuration);
        soundManager.stopBackgroundSound();
      } else {
        stopTimer(countSession: true);
        _showEndNotification();
        return;
      }
    } else {
      _isFocusSession = true;
      _currentDuration = Duration(minutes: _focusDuration);
      soundManager.playSelectedSound();
      _updateQuote();
    }
    _sessionStartTime = DateTime.now();
    _showNotification();
    notifyListeners();
  }

  void _showNotification() {
    String title = _isFocusSession
        ? PomodoroConstants.focusNotificationTitle
        : PomodoroConstants.breakNotificationTitle;
    String body = _isFocusSession
        ? PomodoroConstants.focusNotificationBody[
            Random().nextInt(PomodoroConstants.focusNotificationBody.length)]
        : PomodoroConstants.breakNotificationBody[
            Random().nextInt(PomodoroConstants.breakNotificationBody.length)];
    int durationSeconds = _currentDuration.inSeconds;

    PomodoroNotificationService.showPomodoroNotification(
      title: title,
      body: body,
      durationSeconds: durationSeconds,
    );
  }

  void _showEndNotification() {
    PomodoroNotificationService.showPomodoroNotification(
      title: PomodoroConstants.endNotificationTitle,
      body: PomodoroConstants.endNotificationBody[
          Random().nextInt(PomodoroConstants.endNotificationBody.length)],
      durationSeconds: 0,
    );
  }

  void _resetTimer() {
    _currentSession = 0;
    _isFocusSession = true;
    _currentDuration = Duration(minutes: _focusDuration);
    _sessionStartTime = null;
  }

  void _updateQuote() {
    _currentQuote = PomodoroConstants.motivationalQuotes[
        Random().nextInt(PomodoroConstants.motivationalQuotes.length)];
  }

  void setFocusDuration(int duration) {
    _focusDuration = duration;
    if (_isFocusSession && !_isRunning) {
      _currentDuration = Duration(minutes: duration);
    }
    notifyListeners();
  }

  void setBreakDuration(int duration) {
    _breakDuration = duration;
    if (!_isFocusSession && !_isRunning) {
      _currentDuration = Duration(minutes: duration);
    }
    notifyListeners();
  }

  void setTotalSessions(int sessions) {
    _totalSessions = sessions;
    notifyListeners();
  }

  void toggleSoundMenu() {
    _isSoundMenuOpen = !_isSoundMenuOpen;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    soundManager.dispose();
    super.dispose();
  }
}
