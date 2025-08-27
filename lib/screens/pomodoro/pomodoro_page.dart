import 'package:flutter/cupertino.dart';

class PomodoroPage extends StatelessWidget {
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