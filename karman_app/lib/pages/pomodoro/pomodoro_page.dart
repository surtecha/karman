import 'package:flutter/cupertino.dart';

class PomodoroPage extends StatelessWidget {
  const PomodoroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Pomodoro'),
      ),
      child: Center(
        child: Text('Pomodoro Page'),
      ),
    );
  }
}
