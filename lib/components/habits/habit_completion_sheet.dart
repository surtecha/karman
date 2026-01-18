import 'package:flutter/cupertino.dart';
import 'package:karman/components/common/action_slider.dart';
import 'package:karman/theme/color_scheme.dart';
import 'package:karman/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import '../../models/habit.dart';
import '../../providers/habit_provider.dart';

class HabitCompletionSheet extends StatelessWidget {
  final Habit habit;

  const HabitCompletionSheet({
    super.key,
    required this.habit,
  });

  static void show(BuildContext context, Habit habit) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => HabitCompletionSheet(habit: habit),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, child) {
        return Container(
          decoration: BoxDecoration(
            color: AppColorScheme.backgroundSecondary(theme),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).padding.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColorScheme.textSecondary(theme).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                habit.name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColorScheme.textPrimary(theme),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ActionSlider(
                onComplete: () async {
                  await context.read<HabitProvider>().completeHabit(habit.id!);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
