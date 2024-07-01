import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TimeButton extends StatelessWidget {
  final TimeOfDay? selectedTime;
  final Function(TimeOfDay) onTimeSelected;

  const TimeButton({
    super.key,
    required this.selectedTime,
    required this.onTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: CupertinoColors.tertiarySystemBackground.darkColor,
      child: Text(
        selectedTime == null
            ? 'Select Time'
            : '${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}',
        style: TextStyle(color: CupertinoColors.white),
      ),
      onPressed: () => _showTimePicker(context),
    );
  }

  void _showTimePicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 300,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Container(
              height: 240,
              child: CupertinoDatePicker(
                initialDateTime: DateTime.now().add(Duration(
                    hours: selectedTime?.hour ?? 0,
                    minutes: selectedTime?.minute ?? 0)),
                mode: CupertinoDatePickerMode.time,
                use24hFormat: true,
                onDateTimeChanged: (dateTime) {
                  onTimeSelected(TimeOfDay.fromDateTime(dateTime));
                },
              ),
            ),
            CupertinoButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        ),
      ),
    );
  }
}
