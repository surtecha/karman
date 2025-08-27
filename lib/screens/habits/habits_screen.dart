import 'package:flutter/cupertino.dart';

class HabitsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Habits'),
      ),
      child: Center(
        child: Text(
          'Habits Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}