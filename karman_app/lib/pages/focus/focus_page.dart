import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:karman_app/components/focus/circular_slider.dart';
import 'package:karman_app/components/focus/rolling_menu.dart';
import 'package:karman_app/manager/sound_manager.dart';

class FocusPage extends StatefulWidget {
  const FocusPage({super.key});

  @override
  _FocusPageState createState() => _FocusPageState();
}

class _FocusPageState extends State<FocusPage>
    with SingleTickerProviderStateMixin {
  int _timerValue = 5;
  bool _isTimerRunning = false;
  late Timer _timer;
  int _remainingSeconds = 300;
  int _totalSeconds = 300;
  final SoundManager _soundManager = SoundManager();

  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  @override
  void dispose() {
    _timer.cancel();
    _soundManager.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onSliderValueChanged(int value) {
    setState(() {
      _timerValue = value;
      _remainingSeconds = value * 60;
      _totalSeconds = _remainingSeconds;
    });
  }

  void _toggleTimer() {
    setState(() {
      _isTimerRunning = !_isTimerRunning;
      if (_isTimerRunning) {
        _startTimer();
        _soundManager.playSelectedSound();
      } else {
        _stopTimer(playChime: false);
      }
    });
  }

  void _startTimer() {
    _totalSeconds = _remainingSeconds;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _stopTimer(playChime: true);
        }
      });
    });
  }

  void _stopTimer({required bool playChime}) {
    _timer.cancel();
    _isTimerRunning = false;
    _soundManager.stopBackgroundSound();

    // Close the menu if it's open
    if (_isMenuOpen) {
      _toggleMenu();
    }

    if (playChime) {
      Future.delayed(Duration(seconds: 1), () {
        _soundManager.playChime();
      });
    }

    setState(() {
      _remainingSeconds = _timerValue * 60;
      _totalSeconds = _remainingSeconds;
    });
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  double get _progress {
    if (_totalSeconds == 0) return 0;
    return (_totalSeconds - _remainingSeconds) / _totalSeconds * 115 + 5;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.black,
        trailing: CupertinoButton(
          onPressed: _isTimerRunning ? _toggleMenu : null,
          child: Icon(
            _soundManager.currentIcon,
            color: _isTimerRunning
                ? CupertinoColors.white
                : CupertinoColors.systemGrey,
            size: 32,
          ),
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: CircularSlider(
                  onValueChanged: _onSliderValueChanged,
                  currentValue: _timerValue,
                  isTimerRunning: _isTimerRunning,
                  timeDisplay: _formatTime(_remainingSeconds),
                  progress: _progress,
                  onPlayPause: _toggleTimer,
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(height: 44), // Height of CupertinoNavigationBar
                  SizeTransition(
                    sizeFactor: _animation,
                    axisAlignment: -1,
                    child: Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: RollingMenu(
                        items: _soundManager.sounds,
                        onItemSelected: (Map<String, dynamic> sound) {
                          setState(() {
                            _soundManager.currentSound = sound['file'];
                            if (sound['file'] == null) {
                              _soundManager.stopBackgroundSound();
                            } else if (_isTimerRunning) {
                              _soundManager.playSelectedSound();
                            }
                            _toggleMenu();
                          });
                        },
                        currentSound: _soundManager.currentSound,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
