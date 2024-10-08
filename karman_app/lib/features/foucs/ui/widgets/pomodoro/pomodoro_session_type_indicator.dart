import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PomodoroSessionTypeIndicator extends StatelessWidget {
  final bool isFocusSession;
  final bool isRunning;

  const PomodoroSessionTypeIndicator({
    super.key,
    required this.isFocusSession,
    required this.isRunning,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          isFocusSession && isRunning
              ? 'lib/assets/images/pomodoro/pomo_active.png'
              : 'lib/assets/images/pomodoro/pomo_inactive.png',
          width: 36,
          height: 36,
        ),
        SizedBox(width: 40),
        Icon(
          Icons.coffee,
          color: !isFocusSession && isRunning
              ? CupertinoColors.white
              : CupertinoColors.systemGrey,
          size: 32,
        ),
      ],
    );
  }
}
