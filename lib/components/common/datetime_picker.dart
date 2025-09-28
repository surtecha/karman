import 'package:flutter/cupertino.dart';

class DateTimePickerModal extends StatelessWidget {
  const DateTimePickerModal({
    super.key,
    required this.initialDateTime,
    required this.mode,
    required this.onChanged,
    this.use24hFormat = true,
  });

  final DateTime initialDateTime;
  final CupertinoDatePickerMode mode;
  final ValueChanged<DateTime> onChanged;
  final bool use24hFormat;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 216,
      padding: const EdgeInsets.only(top: 6.0),
      margin: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      color: CupertinoColors.systemBackground.resolveFrom(context),
      child: SafeArea(
        top: false,
        child: CupertinoDatePicker(
          initialDateTime: initialDateTime,
          mode: mode,
          use24hFormat: use24hFormat,
          onDateTimeChanged: onChanged,
        ),
      ),
    );
  }
}