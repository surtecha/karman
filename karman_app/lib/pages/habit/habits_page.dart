import 'package:flutter/cupertino.dart';

class HabitsPage extends StatelessWidget {
  const HabitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Habit Tracking'),
      ),
      child: Center(
        child: Text('Habit Tracking Page'),
      ),
    );
  }
}
