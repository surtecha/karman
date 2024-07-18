import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:karman_app/controllers/habit/habit_controller.dart';
import 'package:karman_app/models/habits/habit.dart';
import 'package:karman_app/pages/habit/habit_completion_sheet.dart';
import 'package:karman_app/pages/habit/habit_details_sheet.dart';
import 'package:provider/provider.dart';

class HabitTile extends StatelessWidget {
  final Habit habit;

  const HabitTile({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: Slidable(
          key: ValueKey(habit.habitId),
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            children: [
              SlidableAction(
                onPressed: (context) => _deleteHabit(context),
                backgroundColor: Colors.black,
                foregroundColor: Colors.redAccent,
                icon: CupertinoIcons.delete,
                label: 'Delete',
              ),
            ],
          ),
          child: GestureDetector(
            onTap: () => _showHabitDetailsSheet(context),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[800]!,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      habit.habitName,
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  _buildStreakIcon(),
                  SizedBox(width: 16),
                  _buildCompletionIcon(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStreakIcon() {
    return SizedBox(
      width: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            CupertinoIcons.flame_fill,
            color: _getStreakColor(),
            size: 24,
          ),
          SizedBox(width: 4),
          Text(
            habit.currentStreak.toString(),
            style: TextStyle(
              color: CupertinoColors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStreakColor() {
    if (habit.currentStreak == 0) {
      return CupertinoColors.systemGrey;
    } else if (habit.currentStreak < 10) {
      return CupertinoColors.white;
    } else if (habit.currentStreak < 21) {
      return CupertinoColors.systemYellow;
    } else {
      return CupertinoColors.systemRed;
    }
  }

  Widget _buildCompletionIcon(BuildContext context) {
    return Container(
      width: 40,
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: habit.isCompletedToday
            ? null
            : () => _showHabitCompletionSheet(context),
        child: Icon(
          habit.isCompletedToday
              ? CupertinoIcons.lock_fill
              : CupertinoIcons.check_mark_circled,
          color: habit.isCompletedToday
              ? CupertinoColors.systemGrey
              : CupertinoColors.white,
          size: 28,
        ),
      ),
    );
  }

  void _showHabitDetailsSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => HabitDetailsSheet(habit: habit),
    );
  }

  void _showHabitCompletionSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => HabitCompletionSheet(habit: habit),
    );
  }

  void _deleteHabit(BuildContext context) {
    if (habit.habitId != null) {
      Provider.of<HabitController>(context, listen: false)
          .deleteHabit(habit.habitId!);
    }
  }
}
