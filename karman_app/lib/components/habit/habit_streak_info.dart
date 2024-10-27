import 'package:flutter/cupertino.dart';

class HabitStreakInfo extends StatelessWidget {
  final int bestStreak;

  const HabitStreakInfo({
    super.key,
    required this.bestStreak,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(CupertinoIcons.flame, color: CupertinoColors.white),
        SizedBox(width: 10),
        Text(
          'Best: $bestStreak',
          style: TextStyle(color: CupertinoColors.white, fontSize: 18),
        ),
      ],
    );
  }
}
