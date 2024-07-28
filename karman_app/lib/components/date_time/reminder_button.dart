import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReminderButton extends StatelessWidget {
  final DateTime? selectedDateTime;
  final Function(DateTime) onReminderSet;
  final bool isEnabled;

  const ReminderButton({
    super.key,
    this.selectedDateTime,
    required this.onReminderSet,
    this.isEnabled = true,
  });

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
    DateTime now = DateTime.now();
    DateTime minimumDate = now.add(Duration(minutes: 1));
    DateTime initialDateTime = selectedDateTime ?? minimumDate;

    // Ensure initialDateTime is not before minimumDate
    if (initialDateTime.isBefore(minimumDate)) {
      initialDateTime = minimumDate;
    }

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
                      if (initialDateTime.isAfter(now)) {
                        onReminderSet(initialDateTime);
                        Navigator.of(context).pop();
                      } else {
                        _showPastDateAlert(context);
                      }
                    },
                  ),
                ],
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.dateAndTime,
                  initialDateTime: initialDateTime,
                  minimumDate: minimumDate,
                  onDateTimeChanged: (DateTime newDateTime) {
                    initialDateTime = newDateTime;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPastDateAlert(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text('Time Travel Not Invented Yet!',
            style: TextStyle(fontSize: 18)),
        content: Text(
            'Unless you have a time machine, we can\'t remind you in the past.'),
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
