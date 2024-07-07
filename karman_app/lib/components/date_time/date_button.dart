import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class DateButton extends StatelessWidget {
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;
  final bool isEnabled;

  const DateButton({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? () => _showDatePicker(context) : null,
      child: Text(
        selectedDate == null
            ? 'Select Date'
            : DateFormat('MMM d, yyyy').format(selectedDate!),
        style: TextStyle(
          color: isEnabled ? CupertinoColors.white : CupertinoColors.systemGrey,
          fontSize: 18,
        ),
      ),
    );
  }

  void _showDatePicker(BuildContext context) {
    DateTime tempPickedDate = selectedDate ?? DateTime.now();

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
                initialDateTime: tempPickedDate,
                mode: CupertinoDatePickerMode.date,
                onDateTimeChanged: (DateTime newDateTime) {
                  tempPickedDate = newDateTime;
                },
              ),
            ),
            CupertinoButton(
              child: Text('OK'),
              onPressed: () {
                onDateSelected(tempPickedDate);
                Navigator.of(context).pop();
              },
            )
          ],
        ),
      ),
    );
  }
}
