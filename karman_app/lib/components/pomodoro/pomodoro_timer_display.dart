import 'package:flutter/cupertino.dart';
import 'package:karman_app/controllers/pomodoro_controller.dart';

class PomodoroTimerDisplay extends StatelessWidget {
  final PomodoroController controller;

  const PomodoroTimerDisplay({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.25,
      child: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              controller.formattedTime,
              style: TextStyle(
                fontSize: 96,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
