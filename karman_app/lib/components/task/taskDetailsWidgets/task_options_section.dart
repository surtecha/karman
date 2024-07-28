import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:karman_app/components/date_time/due_date_button.dart';
import 'package:karman_app/components/date_time/reminder_button.dart';

class TaskOptionsSection extends StatelessWidget {
  final bool isDateEnabled;
  final bool isReminderEnabled;
  final DateTime? dueDate;
  final DateTime? reminder;
  final Function(bool) onDateToggle;
  final Function(bool) onReminderToggle;
  final Function(DateTime) onDateSelected;
  final Function(DateTime) onReminderSet;

  const TaskOptionsSection({
    super.key,
    required this.isDateEnabled,
    required this.isReminderEnabled,
    required this.dueDate,
    required this.reminder,
    required this.onDateToggle,
    required this.onReminderToggle,
    required this.onDateSelected,
    required this.onReminderSet,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildToggleRow(
          icon: CupertinoIcons.calendar,
          title: 'Date',
          isEnabled: isDateEnabled,
          onToggle: onDateToggle,
          child: DueDateButton(
            selectedDate: dueDate,
            onDateSelected: onDateSelected,
            isEnabled: isDateEnabled,
          ),
        ),
        SizedBox(height: 20),
        _buildToggleRow(
          icon: CupertinoIcons.bell,
          title: 'Reminder',
          isEnabled: isReminderEnabled,
          onToggle: onReminderToggle,
          child: ReminderButton(
            selectedDateTime: reminder,
            onReminderSet: onReminderSet,
            isEnabled: isReminderEnabled,
          ),
        ),
      ],
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required String title,
    required bool isEnabled,
    required Function(bool) onToggle,
    required Widget child,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.white),
        SizedBox(width: 10),
        Expanded(child: child),
        CupertinoSwitch(
          value: isEnabled,
          onChanged: onToggle,
          activeColor: Colors.white,
        ),
      ],
    );
  }
}
