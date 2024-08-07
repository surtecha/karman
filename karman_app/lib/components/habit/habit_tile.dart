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
    return Material(
      color: Colors.transparent,
      child: Slidable(
        key: ValueKey(habit.habitId),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (context) => _deleteHabit(context),
              backgroundColor: CupertinoColors.darkBackgroundGray,
              foregroundColor: Colors.redAccent,
              icon: CupertinoIcons.delete,
              label: 'Delete',
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () => _showHabitDetailsSheet(context),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border(
                bottom: BorderSide(
                  color: CupertinoColors.darkBackgroundGray,
                  width: 1,
                ),
              ),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    child: Center(
                      child: _buildCompletionIcon(context),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            habit.habitName,
                            style: TextStyle(
                              color: habit.isCompletedToday
                                  ? Colors.grey[700]
                                  : CupertinoColors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Row(
                              children: [
                                _buildStreakIcon(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStreakIcon() {
    return Row(
      children: [
        Icon(
          CupertinoIcons.flame_fill,
          color: _getStreakColor(),
          size: 20,
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
    return GestureDetector(
      onTap: habit.isCompletedToday
          ? null
          : () => _showHabitCompletionSheet(context),
      child: Transform.scale(
        scale: 1.3,
        child: Icon(
          habit.isCompletedToday
              ? CupertinoIcons.checkmark_circle_fill
              : CupertinoIcons.circle,
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
