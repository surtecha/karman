import 'package:flutter/cupertino.dart';
import 'package:karman_app/features/foucs/logic/pomodoro_controller.dart';

class PomodoroSessionIndicator extends StatelessWidget {
  final PomodoroController controller;

  const PomodoroSessionIndicator({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        controller.totalSessions,
        (index) => Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Icon(
            index < controller.currentSession
                ? CupertinoIcons.circle_fill
                : CupertinoIcons.circle,
            size: 12,
            color: CupertinoColors.white,
          ),
        ),
      ),
    );
  }
}
