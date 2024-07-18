import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:karman_app/controllers/habit/habit_controller.dart';
import 'package:karman_app/models/habits/habit.dart';
import 'package:karman_app/pages/habit/habit_logs_page.dart';
import 'package:karman_app/services/notification_service.dart';
import 'package:provider/provider.dart';

class HabitDetailsSheet extends StatefulWidget {
  final Habit habit;
  final bool isNewHabit;

  const HabitDetailsSheet({
    super.key,
    required this.habit,
    this.isNewHabit = false,
  });

  @override
  _HabitDetailsSheetState createState() => _HabitDetailsSheetState();
}

class _HabitDetailsSheetState extends State<HabitDetailsSheet> {
  late TextEditingController _nameController;
  TimeOfDay? _reminderTime;
  bool _isReminderEnabled = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.habit.habitName);
    if (widget.habit.reminderTime != null) {
      final minutes = widget.habit.reminderTime!.inMinutes;
      _reminderTime = TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
      _isReminderEnabled = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_nameController.text.trim().isEmpty) {
      _showQuirkyDialog('A Habit Without a Name?',
          'Your habit is feeling a bit shy and nameless. How about giving it a snazzy title to boost its confidence?');
      return;
    }

    final updatedHabit = widget.habit.copyWith(
      habitName: _nameController.text.trim(),
      reminderTime: _isReminderEnabled && _reminderTime != null
          ? Duration(hours: _reminderTime!.hour, minutes: _reminderTime!.minute)
          : null,
    );

    if (widget.isNewHabit) {
      context.read<HabitController>().addHabit(updatedHabit);
    } else {
      context.read<HabitController>().updateHabit(updatedHabit);
    }

    if (updatedHabit.reminderTime != null) {
      final now = DateTime.now();
      final scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        _reminderTime!.hour,
        _reminderTime!.minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate.add(Duration(days: 1));
      }

      NotificationService.scheduleNotification(
        id: updatedHabit.habitId!,
        title: 'Habit Reminder',
        body: updatedHabit.habitName,
        scheduledDate: scheduledDate,
        payload: 'habit_${updatedHabit.habitId}',
      );
    } else if (updatedHabit.habitId != null) {
      NotificationService.cancelNotification(updatedHabit.habitId!);
    }

    Navigator.of(context).pop();
  }

  void _showQuirkyDialog(String title, String content) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title, style: TextStyle(fontSize: 18)),
        content: Text(content),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            child: Text('Got it!'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          decoration: BoxDecoration(
            color: CupertinoColors.darkBackgroundGray,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHabitNameField(),
              SizedBox(height: 30),
              _buildReminderToggle(),
              if (!widget.isNewHabit) ...[
                SizedBox(height: 25),
                _buildBestStreakInfo(),
                SizedBox(height: 30),
                _buildViewLogsButton(),
                SizedBox(height: 40),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHabitNameField() {
    return Row(
      children: [
        Expanded(
          child: CupertinoTextField(
            controller: _nameController,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
            placeholder: 'Habit Name',
            placeholderStyle: TextStyle(
              color: Colors.grey,
              fontSize: 24,
            ),
          ),
        ),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _saveChanges,
          child: Icon(
            CupertinoIcons.check_mark_circled,
            color: Colors.white,
            size: 30,
          ),
        ),
      ],
    );
  }

  Widget _buildReminderToggle() {
    return Row(
      children: [
        Icon(CupertinoIcons.bell, color: Colors.white),
        SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: _isReminderEnabled ? _showTimePicker : null,
            child: Text(
              _reminderTime != null ? _formatTime(_reminderTime!) : 'Reminder',
              style: TextStyle(
                color: _isReminderEnabled ? Colors.white : Colors.grey,
                fontSize: 18,
              ),
            ),
          ),
        ),
        CupertinoSwitch(
          value: _isReminderEnabled,
          onChanged: (value) {
            setState(() {
              _isReminderEnabled = value;
              if (!value) _reminderTime = null;
            });
          },
          activeColor: Colors.white,
        ),
      ],
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void _showTimePicker() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: CupertinoDatePicker(
            initialDateTime: DateTime.now().add(Duration(
              hours: _reminderTime?.hour ?? 0,
              minutes: _reminderTime?.minute ?? 0,
            )),
            mode: CupertinoDatePickerMode.time,
            use24hFormat: false,
            onDateTimeChanged: (DateTime newDateTime) {
              setState(() {
                _reminderTime = TimeOfDay.fromDateTime(newDateTime);
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBestStreakInfo() {
    return Row(
      children: [
        Icon(CupertinoIcons.flame, color: Colors.white),
        SizedBox(width: 10),
        Text(
          'Best: ${widget.habit.bestStreak}',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildViewLogsButton() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => HabitLogsPage(habit: widget.habit),
          ),
        );
      },
      child: const Row(
        children: [
          Icon(CupertinoIcons.doc, color: Colors.white),
          SizedBox(width: 10),
          Text(
            'View Logs',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          Spacer(),
          Icon(CupertinoIcons.chevron_right, color: Colors.white),
        ],
      ),
    );
  }
}
