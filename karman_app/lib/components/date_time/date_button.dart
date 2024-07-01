import 'package:flutter/cupertino.dart';

class DateButton extends StatelessWidget {
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;

  const DateButton({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: CupertinoColors.tertiarySystemBackground.darkColor,
      child: Text(
        selectedDate == null
            ? 'Select Date'
            : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
        style: TextStyle(color: CupertinoColors.white),
      ),
      onPressed: () => _showDatePicker(context),
    );
  }

  void _showDatePicker(BuildContext context) {
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
                initialDateTime: selectedDate ?? DateTime.now(),
                mode: CupertinoDatePickerMode.date,
                onDateTimeChanged: onDateSelected,
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
