import 'package:flutter/cupertino.dart';
import 'package:karman_app/models/habits/habit.dart';
import 'package:karman_app/pages/habit/habit_logs_page.dart';

class HabitLogsButton extends StatelessWidget {
  final Habit habit;

  const HabitLogsButton({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => HabitLogsPage(habit: habit),
          ),
        );
      },
      child: const Row(
        children: [
          Icon(CupertinoIcons.doc_text, color: CupertinoColors.white),
          SizedBox(width: 10),
          Text(
            'View Logs',
            style: TextStyle(color: CupertinoColors.white, fontSize: 18),
          ),
          Spacer(),
          Icon(CupertinoIcons.chevron_right, color: CupertinoColors.white),
        ],
      ),
    );
  }
}
