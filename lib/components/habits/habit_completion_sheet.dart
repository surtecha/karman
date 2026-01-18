import 'package:flutter/cupertino.dart';
import 'package:action_slider/action_slider.dart';
import 'package:karman/components/habits/habit_streak_display.dart';
import 'package:karman/theme/color_scheme.dart';
import 'package:karman/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import '../../models/habit.dart';
import '../../providers/habit_provider.dart';

class HabitCompletionSheet extends StatefulWidget {
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
  State<HabitCompletionSheet> createState() => _HabitCompletionSheetState();
}

class _HabitCompletionSheetState extends State<HabitCompletionSheet> {
  int _displayStreak = 0;
  int _displayMaxStreak = 0;
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    _displayStreak = widget.habit.currentStreak;
    _displayMaxStreak = widget.habit.maxStreak;
  }

  Future<void> _handleComplete(ActionSliderController controller) async {
    if (!mounted || _isCompleting) return;
    
    setState(() => _isCompleting = true);
    
    controller.success();
    
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (!mounted) return;
    
    setState(() {
      _displayStreak = widget.habit.currentStreak + 1;
      _displayMaxStreak = _displayStreak > widget.habit.maxStreak 
          ? _displayStreak 
          : widget.habit.maxStreak;
    });
    
    await context.read<HabitProvider>().completeHabit(widget.habit.id!);
    
    if (!mounted) return;
    
    await Future.delayed(const Duration(milliseconds: 1000));
    
    if (mounted) {
      Navigator.of(context).pop();
    }
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
                widget.habit.name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColorScheme.textPrimary(theme),
                ),
                textAlign: TextAlign.center,
              ),
              if (widget.habit.description != null && widget.habit.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  widget.habit.description!,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColorScheme.textSecondary(theme),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 32),
              HabitStreakDisplay(
                currentStreak: _displayStreak,
                maxStreak: _displayMaxStreak,
                theme: theme,
              ),
              const SizedBox(height: 32),
              Consumer<ThemeProvider>(
                builder: (context, sliderTheme, _) {
                  return ActionSlider.standard(
                    sliderBehavior: SliderBehavior.stretch,
                    width: double.infinity,
                    backgroundColor: AppColorScheme.surfaceElevated(sliderTheme),
                    toggleColor: AppColorScheme.backgroundPrimary(sliderTheme),
                    icon: const Icon(
                      CupertinoIcons.chevron_right,
                      size: 24,
                    ),
                    successIcon: const Icon(
                      CupertinoIcons.checkmark,
                      size: 24,
                      color: CupertinoColors.systemGreen,
                    ),
                    action: (controller) => _handleComplete(controller),
                    child: Text(
                      'Swipe to complete',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColorScheme.textSecondary(sliderTheme),
                      ),
                    ),
                  );
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