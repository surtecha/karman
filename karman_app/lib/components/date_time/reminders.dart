import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ReminderButton extends StatelessWidget {
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final Function(DateTime?, TimeOfDay?) onReminderSet;

  const ReminderButton({
    super.key,
    this.selectedDate,
    this.selectedTime,
    required this.onReminderSet,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: CupertinoColors.tertiarySystemBackground.darkColor,
      onPressed: () => _showReminderPicker(context),
      child: Text(
        _getReminderText(),
        style: TextStyle(color: CupertinoColors.white),
      ),
    );
  }

  String _getReminderText() {
    if (selectedDate != null && selectedTime != null) {
      return '${_formatDate(selectedDate!)} at ${_formatTime(selectedTime!)}';
    } else {
      return 'Set Reminder';
    }
  }

  void _showReminderPicker(BuildContext context) {
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
                      onReminderSet(selectedDate, selectedTime);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.dateAndTime,
                  initialDateTime: selectedDate ?? DateTime.now(),
                  onDateTimeChanged: (DateTime newDateTime) {
                    onReminderSet(
                      newDateTime,
                      TimeOfDay.fromDateTime(newDateTime),
                    );
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
    return '${date.month}/${date.day}/${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final hours = time.hourOfPeriod;
    final minutes = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hours:$minutes $period';
  }
}
