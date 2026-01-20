import 'package:flutter/cupertino.dart';
import 'package:karman/components/habits/habit_completion_overlay.dart';
import 'package:karman/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import '../../models/habit.dart';

class HabitCompletionSheet extends StatelessWidget {
  final Habit habit;

  const HabitCompletionSheet({
    super.key,
    required this.habit,
  });

  static void show(BuildContext context, Habit habit) {
    showCupertinoModalPopup(
      context: context,
      barrierColor: CupertinoColors.black.withOpacity(0.75),
      builder: (context) => HabitCompletionSheet(habit: habit),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, child) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            color: CupertinoColors.transparent,
            child: Center(
              child: GestureDetector(
                onTap: () {},
                child: HabitCompletionOverlay(habit: habit),
              ),
            ),
          ),
        );
      },
    );
  }
}
