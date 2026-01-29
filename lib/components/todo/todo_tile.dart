import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:karman/theme/color_scheme.dart';
import 'package:karman/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import '../../models/todo.dart';

class TodoTile extends StatefulWidget {
  final Todo todo;
  final VoidCallback onTap;
  final Function(bool?) onToggle;
  final VoidCallback onDelete;
  final bool isSelected;
  final bool isSelectionMode;
  final bool showPriorityBorder;
  final bool enableSwipeToDelete;
  final bool showCompletionCheckbox;

  const TodoTile({
    super.key,
    required this.todo,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
    this.isSelected = false,
    this.isSelectionMode = false,
    this.showPriorityBorder = false,
    this.enableSwipeToDelete = true,
    this.showCompletionCheckbox = true,
  });

  @override
  State<TodoTile> createState() => _TodoTileState();
}

class _TodoTileState extends State<TodoTile> {
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

  String _formatRepeatDays() {
    if (widget.todo.repeatDays.isEmpty) return '';

    if (widget.todo.repeatDays.length == 7) return 'Weekly';

    if (widget.todo.repeatDays.length == 5 &&
        widget.todo.repeatDays.containsAll([1, 2, 3, 4, 5])) {
      return 'Weekdays';
    }

    if (widget.todo.repeatDays.length == 2 &&
        widget.todo.repeatDays.containsAll([6, 7])) {
      return 'Weekends';
    }

    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return widget.todo.repeatDays.map((day) => dayNames[day - 1]).join(', ');
  }

  String _formatReminder() {
    if (widget.todo.reminder == null && !widget.todo.isRepeating) return '';

    if (widget.todo.isRepeating && widget.todo.repeatDays.isNotEmpty) {
      final daysText = _formatRepeatDays();

      if (widget.todo.reminder != null) {
        final hour =
            widget.todo.reminder!.hour == 0
                ? 12
                : widget.todo.reminder!.hour > 12
                ? widget.todo.reminder!.hour - 12
                : widget.todo.reminder!.hour;
        final minute = widget.todo.reminder!.minute.toString().padLeft(2, '0');
        final period = widget.todo.reminder!.hour < 12 ? 'AM' : 'PM';
        return '$daysText at $hour:$minute $period';
      }
      return daysText;
    }

    if (widget.todo.reminder == null) return '';

    final now = DateTime.now();
    final reminder = widget.todo.reminder!;
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
    if (widget.todo.reminder == null || widget.todo.isVisuallyCompleted)
      return false;

    if (widget.todo.isRepeating && widget.todo.repeatDays.isNotEmpty) {
      final now = DateTime.now();
      final currentWeekday = now.weekday;
      if (!widget.todo.repeatDays.contains(currentWeekday)) return false;

      final reminderTime = DateTime(
        now.year,
        now.month,
        now.day,
        widget.todo.reminder!.hour,
        widget.todo.reminder!.minute,
      );
      return now.isAfter(reminderTime);
    }

    return DateTime.now().isAfter(widget.todo.reminder!);
  }

  Color _getPriorityColor(BuildContext context, ThemeProvider theme) {
    switch (widget.todo.priority) {
      case 0:
        return AppColorScheme.accentColors['green']!.resolveFrom(context);
      case 1:
        return AppColorScheme.accentColors['orange']!.resolveFrom(context);
      case 2:
        return AppColorScheme.accentColors['red']!.resolveFrom(context);
      default:
        return AppColorScheme.accentColors['orange']!.resolveFrom(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, child) {
        return Dismissible(
          key: Key('${widget.todo.id}_dismissible'),
          direction:
              !widget.enableSwipeToDelete || widget.isSelectionMode
                  ? DismissDirection.none
                  : DismissDirection.endToStart,
          onDismissed: (_) {
            HapticFeedback.mediumImpact();
            widget.onDelete();
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
            decoration: BoxDecoration(
              color:
                  widget.isSelected
                      ? AppColorScheme.accent(theme, context).withOpacity(0.1)
                      : AppColorScheme.backgroundPrimary(theme),
              border:
                  widget.showPriorityBorder
                      ? Border(
                        left: BorderSide(
                          color: _getPriorityColor(context, theme),
                          width: 4,
                        ),
                      )
                      : null,
            ),
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              onPressed:
                  widget.isSelectionMode
                      ? () => widget.onToggle(null)
                      : widget.onTap,
              child: Row(
                children: [
                  if (widget.showCompletionCheckbox) ...[
                    GestureDetector(
                      onTap:
                          () =>
                              widget.onToggle(!widget.todo.isVisuallyCompleted),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                widget.isSelectionMode && widget.isSelected
                                    ? AppColorScheme.accent(theme, context)
                                    : widget.todo.isVisuallyCompleted
                                    ? AppColorScheme.accent(theme, context)
                                    : AppColorScheme.textSecondary(theme),
                            width: 2,
                          ),
                          color:
                              widget.isSelectionMode && widget.isSelected
                                  ? AppColorScheme.accent(theme, context)
                                  : widget.todo.isVisuallyCompleted
                                  ? AppColorScheme.accent(theme, context)
                                  : null,
                        ),
                        child:
                            (widget.isSelectionMode && widget.isSelected) ||
                                    widget.todo.isVisuallyCompleted
                                ? Icon(
                                  CupertinoIcons.checkmark,
                                  size: 16,
                                  color: AppColorScheme.backgroundPrimary(
                                    theme,
                                  ),
                                )
                                : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (!widget.showCompletionCheckbox &&
                      widget.isSelectionMode) ...[
                    Icon(
                      widget.isSelected
                          ? CupertinoIcons.checkmark_circle_fill
                          : CupertinoIcons.circle,
                      color:
                          widget.isSelected
                              ? AppColorScheme.accent(theme, context)
                              : AppColorScheme.textSecondary(theme),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.todo.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color:
                                widget.todo.isVisuallyCompleted
                                    ? AppColorScheme.textSecondary(theme)
                                    : AppColorScheme.textPrimary(theme),
                          ),
                        ),
                        if (widget.todo.description?.isNotEmpty == true) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.todo.description!,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColorScheme.textSecondary(theme),
                              decoration:
                                  widget.todo.isVisuallyCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                            ),
                          ),
                        ],
                        if (widget.todo.reminder != null ||
                            widget.todo.isRepeating) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                widget.todo.isRepeating
                                    ? CupertinoIcons.repeat
                                    : CupertinoIcons.bell,
                                size: 14,
                                color:
                                    _isMissedReminder()
                                        ? AppColorScheme.destructive(context)
                                        : AppColorScheme.accent(theme, context),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatReminder(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      _isMissedReminder()
                                          ? AppColorScheme.destructive(context)
                                          : AppColorScheme.accent(
                                            theme,
                                            context,
                                          ),
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
