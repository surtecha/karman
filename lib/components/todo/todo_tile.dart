import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:karman/theme/color_scheme.dart';
import 'package:karman/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import '../../models/todo.dart';

class TodoTile extends StatelessWidget {
  final Todo todo;
  final VoidCallback onTap;
  final Function(bool?) onToggle;
  final VoidCallback onDelete;
  final bool isSelected;
  final bool isSelectionMode;

  const TodoTile({
    super.key,
    required this.todo,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
    this.isSelected = false,
    this.isSelectionMode = false,
  });

  String _formatRepeatDays() {
    if (todo.repeatDays.isEmpty) return '';

    if (todo.repeatDays.length == 7) return 'Weekly';

    if (todo.repeatDays.length == 5 &&
        todo.repeatDays.containsAll([1, 2, 3, 4, 5])) {
      return 'Weekdays';
    }

    if (todo.repeatDays.length == 2 &&
        todo.repeatDays.containsAll([6, 7])) {
      return 'Weekends';
    }

    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return todo.repeatDays.map((day) => dayNames[day - 1]).join(', ');
  }

  String _formatReminder() {
    if (todo.reminder == null && !todo.isRepeating) return '';

    if (todo.isRepeating && todo.repeatDays.isNotEmpty) {
      final daysText = _formatRepeatDays();

      if (todo.reminder != null) {
        final hour =
            todo.reminder!.hour == 0
                ? 12
                : todo.reminder!.hour > 12
                ? todo.reminder!.hour - 12
                : todo.reminder!.hour;
        final minute = todo.reminder!.minute.toString().padLeft(2, '0');
        final period = todo.reminder!.hour < 12 ? 'AM' : 'PM';
        return '$daysText at $hour:$minute $period';
      }
      return daysText;
    }

    if (todo.reminder == null) return '';

    final now = DateTime.now();
    final reminder = todo.reminder!;
    final today = DateTime(now.year, now.month, now.day);
    final reminderDay = DateTime(reminder.year, reminder.month, reminder.day);

    String dateStr =
        reminderDay == today
            ? 'Today'
            : reminderDay == today.add(const Duration(days: 1))
            ? 'Tomorrow'
            : '${reminder.day}/${reminder.month}';

    final hour =
        reminder.hour == 0
            ? 12
            : reminder.hour > 12
            ? reminder.hour - 12
            : reminder.hour;
    final minute = reminder.minute.toString().padLeft(2, '0');
    final period = reminder.hour < 12 ? 'AM' : 'PM';

    return '$dateStr at $hour:$minute $period';
  }

  bool _isMissedReminder() {
    if (todo.reminder == null || todo.isVisuallyCompleted) return false;
    
    if (todo.isRepeating && todo.repeatDays.isNotEmpty) {
      final now = DateTime.now();
      final currentWeekday = now.weekday;
      if (!todo.repeatDays.contains(currentWeekday)) return false;
      
      final reminderTime = DateTime(
        now.year,
        now.month,
        now.day,
        todo.reminder!.hour,
        todo.reminder!.minute,
      );
      return now.isAfter(reminderTime);
    }
    
    return DateTime.now().isAfter(todo.reminder!);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, child) {
        return Dismissible(
          key: Key('${todo.id}_dismissible'),
          direction:
              isSelectionMode
                  ? DismissDirection.none
                  : DismissDirection.endToStart,
          onDismissed: (_) {
            HapticFeedback.mediumImpact();
            onDelete();
          },
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: AppColorScheme.backgroundSecondary(theme),
            child: Icon(
              CupertinoIcons.trash,
              color: AppColorScheme.destructive(context),
              size: 24,
            ),
          ),
          child: Container(
            color:
                isSelected
                    ? AppColorScheme.accent(theme, context).withOpacity(0.1)
                    : AppColorScheme.backgroundPrimary(theme),
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              onPressed: isSelectionMode ? () => onToggle(null) : onTap,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => onToggle(!todo.isVisuallyCompleted),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              isSelectionMode && isSelected
                                  ? AppColorScheme.accent(theme, context)
                                  : todo.isVisuallyCompleted
                                  ? AppColorScheme.accent(theme, context)
                                  : AppColorScheme.textSecondary(theme),
                          width: 2,
                        ),
                        color:
                            isSelectionMode && isSelected
                                ? AppColorScheme.accent(theme, context)
                                : todo.isVisuallyCompleted
                                ? AppColorScheme.accent(theme, context)
                                : null,
                      ),
                      child:
                          (isSelectionMode && isSelected) ||
                                  todo.isVisuallyCompleted
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
                          todo.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color:
                                todo.isVisuallyCompleted
                                    ? AppColorScheme.textSecondary(theme)
                                    : AppColorScheme.textPrimary(theme),
                          ),
                        ),
                        if (todo.description?.isNotEmpty == true) ...[
                          const SizedBox(height: 4),
                          Text(
                            todo.description!,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColorScheme.textSecondary(theme),
                              decoration:
                                  todo.isVisuallyCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                            ),
                          ),
                        ],
                        if (todo.reminder != null || todo.isRepeating) ...[ 
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                todo.isRepeating 
                                    ? CupertinoIcons.repeat 
                                    : CupertinoIcons.bell,
                                size: 14,
                                color: _isMissedReminder()
                                    ? AppColorScheme.destructive(context)
                                    : AppColorScheme.accent(theme, context),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatReminder(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _isMissedReminder()
                                      ? AppColorScheme.destructive(context)
                                      : AppColorScheme.accent(theme, context),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
