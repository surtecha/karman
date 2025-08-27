import 'package:flutter/cupertino.dart';

class PomodoroScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Pomodoro'),
      ),
      child: Center(
        child: Text(
          'Pomodoro Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}