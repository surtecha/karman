import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:karman/theme/color_scheme.dart';
import 'package:karman/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import '../../models/habit.dart';

class HabitTile extends StatefulWidget {
  final Habit habit;
  final VoidCallback onTap;
  final VoidCallback onCheckTap;
  final bool isSelected;
  final bool isSelectionMode;

  const HabitTile({
    super.key,
    required this.habit,
    required this.onTap,
    required this.onCheckTap,
    this.isSelected = false,
    this.isSelectionMode = false,
  });

  @override
  State<HabitTile> createState() => _HabitTileState();
}

class _HabitTileState extends State<HabitTile> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  String _formatReminder() {
    final hour =
        widget.habit.reminder.hour == 0
            ? 12
            : widget.habit.reminder.hour > 12
            ? widget.habit.reminder.hour - 12
            : widget.habit.reminder.hour;
    final minute = widget.habit.reminder.minute.toString().padLeft(2, '0');
    final period = widget.habit.reminder.hour < 12 ? 'AM' : 'PM';

    if (widget.habit.customReminder && widget.habit.reminderDays.isNotEmpty) {
      final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final days = widget.habit.reminderDays
          .map((day) => dayNames[day - 1])
          .join(', ');
      return '$days at $hour:$minute $period';
    }

    return 'Daily at $hour:$minute $period';
  }

  bool _isOverdue() {
    // Only check if habit is scheduled for today and not completed
    if (!widget.habit.isScheduledForToday || widget.habit.isCompletedToday) {
      return false;
    }

    final now = DateTime.now();
    final todayReminder = DateTime(
      now.year,
      now.month,
      now.day,
      widget.habit.reminder.hour,
      widget.habit.reminder.minute,
    );

    return now.isAfter(todayReminder);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, child) {
        final streakColor =
            widget.habit.isStreakActive
                ? AppColorScheme.accentColors['orange']!.resolveFrom(context)
                : AppColorScheme.textSecondary(theme);

        return GestureDetector(
          onTap: widget.isSelectionMode ? null : widget.onTap,
          child: Container(
            decoration: BoxDecoration(
              color:
                  widget.isSelected
                      ? AppColorScheme.accent(theme, context).withOpacity(0.1)
                      : AppColorScheme.backgroundPrimary(theme),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap:
                      widget.isSelectionMode ? widget.onTap : widget.onCheckTap,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            widget.isSelectionMode && widget.isSelected
                                ? AppColorScheme.accent(theme, context)
                                : widget.habit.isCompletedToday
                                ? AppColorScheme.accent(theme, context)
                                : AppColorScheme.textSecondary(theme),
                        width: 2,
                      ),
                      color:
                          widget.isSelectionMode && widget.isSelected
                              ? AppColorScheme.accent(theme, context)
                              : widget.habit.isCompletedToday
                              ? AppColorScheme.accent(theme, context)
                              : null,
                    ),
                    child:
                        (widget.isSelectionMode && widget.isSelected) ||
                                widget.habit.isCompletedToday
                            ? Icon(
                              CupertinoIcons.checkmark,
                              size: 16,
                              color: AppColorScheme.backgroundPrimary(theme),
                            )
                            : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.habit.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColorScheme.textPrimary(theme),
                        ),
                      ),
                      if (widget.habit.description?.isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.habit.description!,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColorScheme.textSecondary(theme),
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.bell,
                            size: 14,
                            color:
                                _isOverdue()
                                    ? AppColorScheme.destructive(context)
                                    : AppColorScheme.accent(theme, context),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatReminder(),
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  _isOverdue()
                                      ? AppColorScheme.destructive(context)
                                      : AppColorScheme.accent(theme, context),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.flame_fill,
                      size: 20,
                      color: streakColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.habit.currentStreak}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: streakColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
