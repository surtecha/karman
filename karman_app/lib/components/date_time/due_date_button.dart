import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class DueDateButton extends StatelessWidget {
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;
  final bool isEnabled;

  const DueDateButton({
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
    DateTime minimumDate = DateTime.now().subtract(Duration(days: 1));

    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 300,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            SizedBox(
              height: 240,
              child: CupertinoDatePicker(
                initialDateTime: tempPickedDate,
                minimumDate: minimumDate,
                mode: CupertinoDatePickerMode.date,
                onDateTimeChanged: (DateTime newDateTime) {
                  tempPickedDate = newDateTime;
                },
              ),
            ),
            CupertinoButton(
              child: Text('OK'),
              onPressed: () {
                if (tempPickedDate.isAfter(minimumDate)) {
                  onDateSelected(tempPickedDate);
                  Navigator.of(context).pop();
                } else {
                  _showPastDateError(context);
                }
              },
            )
          ],
        ),
      ),
    );
  }

  void _showPastDateError(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text('Time Travel Alert!'),
        content: Text('Please select a date in the future.'),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
