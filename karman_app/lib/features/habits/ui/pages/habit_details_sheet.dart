import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:karman_app/core/services/notifications/notification_service.dart';
import 'package:karman_app/features/habits/data/habit.dart';
import 'package:karman_app/features/habits/logic/habit_controller.dart';
import 'package:karman_app/features/habits/ui/pages/habit_logs_page.dart';
import 'package:karman_app/features/habits/ui/widgets/habit_reminder.dart';
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
  TimeOfDay? _reminderTime;
  bool _isReminderEnabled = false;
  bool _isHabitNameEmpty = true;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.habit.habitName);
    _nameFocusNode = FocusNode();
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
                      widget.habit.reminderTime!.inMinutes % 60));
    });
  }

  void _saveChanges() {
    if (!_hasChanges) return;

    final updatedHabit = widget.habit.copyWith(
      habitName: _nameController.text.trim(),
      reminderTime: _isReminderEnabled && _reminderTime != null
          ? Duration(hours: _reminderTime!.hour, minutes: _reminderTime!.minute)
          : null,
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

    if (scheduledDate.isBefore(now)) {
      scheduledDate.add(Duration(days: 1));
    }

    NotificationService.scheduleNotification(
      id: habit.habitId!,
      title: 'Let\'s do it!',
      body: habit.habitName,
      scheduledDate: scheduledDate,
      payload: 'habit_${habit.habitId}',
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
              _buildHabitNameField(),
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
            focusNode: _nameFocusNode,
            style: TextStyle(
              color: _isHabitNameEmpty
                  ? CupertinoColors.systemGrey
                  : CupertinoColors.white,
              fontSize: 20,
            ),
            placeholder: 'Habit Name',
            placeholderStyle: TextStyle(
              color: CupertinoColors.systemGrey,
              fontSize: 20,
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
        ),
        SizedBox(width: 20),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _hasChanges && !_isHabitNameEmpty ? _saveChanges : null,
          child: Text(
            'Save',
            style: TextStyle(
              color: _hasChanges && !_isHabitNameEmpty
                  ? CupertinoColors.white
                  : CupertinoColors.systemGrey,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBestStreakInfo() {
    return Row(
      children: [
        Icon(CupertinoIcons.flame, color: CupertinoColors.white),
        SizedBox(width: 10),
        Text(
          'Best: ${widget.habit.bestStreak}',
          style: TextStyle(color: CupertinoColors.white, fontSize: 18),
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
          Icon(CupertinoIcons.doc_text, color: CupertinoColors.white),
          SizedBox(width: 10),
          Text(
            'View Logs',
            style: TextStyle(color: CupertinoColors.white, fontSize: 18),
          ),
          Spacer(),
          Icon(CupertinoIcons.chevron_right, color: CupertinoColors.white),
        ],
      ),
    );
  }
}
