import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReminderButton extends StatelessWidget {
  final DateTime? selectedDateTime;
  final Function(DateTime) onReminderSet;
  final bool isEnabled;

  const ReminderButton({
    Key? key,
    this.selectedDateTime,
    required this.onReminderSet,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? () => _showReminderPicker(context) : null,
      child: Text(
        _getReminderText(),
        style: TextStyle(
          color: isEnabled ? CupertinoColors.white : CupertinoColors.systemGrey,
          fontSize: 18,
        ),
      ),
    );
  }

  String _getReminderText() {
    if (selectedDateTime != null) {
      return '${_formatDate(selectedDateTime!)} at ${_formatTime(TimeOfDay.fromDateTime(selectedDateTime!))}';
    } else {
      return 'Set Reminder';
    }
  }

  void _showReminderPicker(BuildContext context) {
    DateTime tempDateTime = selectedDateTime ?? DateTime.now();

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  CupertinoButton(
                    child: Text('Done'),
                    onPressed: () {
                      onReminderSet(tempDateTime);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.dateAndTime,
                  initialDateTime: tempDateTime,
                  onDateTimeChanged: (DateTime newDateTime) {
                    tempDateTime = newDateTime;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  String _formatTime(TimeOfDay time) {
    final hours = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minutes = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hours:$minutes $period';
  }
}
