import 'package:flutter/cupertino.dart';
import 'package:karman/theme/color_scheme.dart';
import 'package:karman/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:karman/components/common/custom_cupertino_switch.dart';
import 'package:karman/components/common/datetime_picker.dart';
import 'package:karman/components/common/form_row_with_icon.dart';
import 'package:karman/components/common/select_button.dart';
import 'package:karman/components/common/repeat_day_selector.dart';
import 'package:karman/utilities/extensions.dart';

class ReminderSection extends StatelessWidget {
  final bool hasReminder;
  final DateTime? selectedDate;
  final DateTime? selectedTime;
  final bool isRepeating;
  final Set<int> repeatDays;
  final Function(bool) onReminderToggle;
  final Function(DateTime) onDateChanged;
  final Function(DateTime) onTimeChanged;
  final Function(bool) onRepeatToggle;
  final Function(int) onDayToggle;

  const ReminderSection({
    super.key,
    required this.hasReminder,
    required this.selectedDate,
    required this.selectedTime,
    required this.isRepeating,
    required this.repeatDays,
    required this.onReminderToggle,
    required this.onDateChanged,
    required this.onTimeChanged,
    required this.onRepeatToggle,
    required this.onDayToggle,
  });

  void _showDatePicker(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder:
          (_) => DateTimePickerModal(
            initialDateTime: selectedDate ?? DateTime.now(),
            mode: CupertinoDatePickerMode.date,
            onChanged: onDateChanged,
          ),
    );
  }

  void _showTimePicker(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder:
          (_) => DateTimePickerModal(
            initialDateTime: selectedTime ?? DateTime.now(),
            mode: CupertinoDatePickerMode.time,
            use24hFormat: false,
            onChanged: onTimeChanged,
          ),
    );
  }

  String _formatDate() =>
      selectedDate?.let((d) => '${d.day}/${d.month}/${d.year}') ??
      'Select Date';

  String _formatTime() =>
      selectedTime?.let((t) {
        final hour =
            t.hour == 0
                ? 12
                : t.hour > 12
                ? t.hour - 12
                : t.hour;
        final minute = t.minute.toString().padLeft(2, '0');
        final period = t.hour < 12 ? 'AM' : 'PM';
        return '$hour:$minute $period';
      }) ??
      'Select Time';

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, child) {
        return CupertinoFormSection.insetGrouped(
          backgroundColor: AppColorScheme.backgroundSecondary(theme),
          children: [
            FormRowWithIcon(
              icon: CupertinoIcons.bell,
              label: 'Reminder',
              context: context,
              child: CustomSwitch(
                value: hasReminder,
                onChanged: onReminderToggle,
              ),
            ),
            if (hasReminder) ...[ 
              FormRowWithIcon(
                icon: CupertinoIcons.repeat,
                label: 'Repeat',
                context: context,
                child: CustomSwitch(
                  value: isRepeating,
                  onChanged: onRepeatToggle,
                ),
              ),
              if (isRepeating) ...[
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: RepeatDaySelector(
                    selectedDays: repeatDays,
                    onDayToggle: onDayToggle,
                  ),
                ),
              ] else ...[
                FormRowWithIcon(
                  icon: CupertinoIcons.calendar,
                  label: 'Date',
                  context: context,
                  child: SelectButton(
                    text: _formatDate(),
                    color: AppColorScheme.accent(theme, context),
                    onPressed: () => _showDatePicker(context),
                  ),
                ),
              ],
              FormRowWithIcon(
                icon: CupertinoIcons.time,
                label: 'Time',
                context: context,
                child: SelectButton(
                  text: _formatTime(),
                  color: AppColorScheme.accent(theme, context),
                  onPressed: () => _showTimePicker(context),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
