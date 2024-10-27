import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:karman_app/components/habit/habit_logs_button.dart';
import 'package:karman_app/components/habit/habit_name_field.dart';
import 'package:karman_app/components/habit/habit_schedule_selector.dart';
import 'package:karman_app/components/habit/habit_streak_info.dart';
import 'package:karman_app/components/reminders/habit_reminder.dart';
import 'package:karman_app/controllers/habit_controller.dart';
import 'package:karman_app/models/habits/habit.dart';
import 'package:karman_app/models/habits/habit_schedule.dart';
import 'package:karman_app/services/notifications/notification_service.dart';
import 'package:provider/provider.dart';

class HabitDetailsSheet extends StatefulWidget {
  final Habit habit;
  final bool isNewHabit;
  final bool autoFocus;

  const HabitDetailsSheet({
    super.key,
    required this.habit,
    this.isNewHabit = false,
    this.autoFocus = false,
  });

  @override
  HabitDetailsSheetState createState() => HabitDetailsSheetState();
}

class HabitDetailsSheetState extends State<HabitDetailsSheet> {
  late TextEditingController _nameController;
  late FocusNode _nameFocusNode;
  late HabitSchedule _schedule;
  TimeOfDay? _reminderTime;
  bool _isReminderEnabled = false;
  bool _isHabitNameEmpty = true;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.habit.habitName);
    _nameFocusNode = FocusNode();
    _schedule = widget.habit.schedule;
    _isHabitNameEmpty = _nameController.text.isEmpty;
    _nameController.addListener(_updateState);
    if (widget.habit.reminderTime != null) {
      final minutes = widget.habit.reminderTime!.inMinutes;
      _reminderTime = TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
      _isReminderEnabled = true;
    }
    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(_nameFocusNode);
      });
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_updateState);
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  void _updateState() {
    setState(() {
      _isHabitNameEmpty = _nameController.text.isEmpty;
      _hasChanges = _nameController.text != widget.habit.habitName ||
          _isReminderEnabled != (widget.habit.reminderTime != null) ||
          (_isReminderEnabled &&
              _reminderTime != null &&
              widget.habit.reminderTime != null &&
              (_reminderTime!.hour != widget.habit.reminderTime!.inHours ||
                  _reminderTime!.minute !=
                      widget.habit.reminderTime!.inMinutes % 60)) ||
          _schedule != widget.habit.schedule;
    });
  }

  void _saveChanges() {
    if (!_hasChanges) return;

    final updatedHabit = widget.habit.copyWith(
      habitName: _nameController.text.trim(),
      reminderTime: _isReminderEnabled && _reminderTime != null
          ? Duration(hours: _reminderTime!.hour, minutes: _reminderTime!.minute)
          : null,
      schedule: _schedule,
    );

    final habitController = context.read<HabitController>();

    if (widget.isNewHabit) {
      habitController.addHabit(updatedHabit);
    } else {
      habitController.updateHabit(updatedHabit);
    }

    if (updatedHabit.habitId != null) {
      if (_isReminderEnabled && _reminderTime != null) {
        _scheduleReminder(updatedHabit);
      } else {
        NotificationService.cancelNotification(updatedHabit.habitId!);
      }
    }

    Navigator.of(context).pop();
  }

  void _scheduleReminder(Habit habit) {
    final now = DateTime.now();
    final scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      _reminderTime!.hour,
      _reminderTime!.minute,
    );

    NotificationService.scheduleNotification(
      id: habit.habitId!,
      title: 'Let\'s do it!',
      body: habit.habitName,
      scheduledDate: scheduledDate,
      payload: 'habit_${habit.habitId}',
      selectedDays: habit.schedule.selectedDaysList,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 40,
            left: 20,
            right: 20,
            top: 20,
          ),
          decoration: BoxDecoration(
            color: CupertinoColors.darkBackgroundGray,
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HabitNameField(
                controller: _nameController,
                focusNode: _nameFocusNode,
                isHabitNameEmpty: _isHabitNameEmpty,
                hasChanges: _hasChanges,
                onSave: _saveChanges,
              ),
              SizedBox(height: 30),
              HabitReminder(
                isEnabled: _isReminderEnabled,
                time: _reminderTime,
                onToggle: (value) {
                  setState(() {
                    _isReminderEnabled = value;
                    if (!value) _reminderTime = null;
                    _updateState();
                  });
                },
                onTimeSelected: (TimeOfDay time) {
                  setState(() {
                    _reminderTime = time;
                    _updateState();
                  });
                },
              ),
              SizedBox(height: 30),
              HabitScheduleSelector(
                schedule: _schedule,
                onScheduleChanged: (newSchedule) {
                  setState(() {
                    _schedule = newSchedule;
                    _updateState();
                  });
                },
              ),
              if (!widget.isNewHabit) ...[
                SizedBox(height: 25),
                HabitStreakInfo(bestStreak: widget.habit.bestStreak),
                SizedBox(height: 30),
                HabitLogsButton(habit: widget.habit),
                SizedBox(height: 40),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
