import 'package:flutter/cupertino.dart';
import 'package:karman_app/models/habits/habit_schedule.dart';

class HabitScheduleSelector extends StatelessWidget {
  final HabitSchedule schedule;
  final Function(HabitSchedule) onScheduleChanged;

  const HabitScheduleSelector({
    super.key,
    required this.schedule,
    required this.onScheduleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selectedDays = schedule.selectedDaysList;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              CupertinoIcons.repeat,
              color: CupertinoColors.white,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Repeat on',
              style: TextStyle(
                color: CupertinoColors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _DayButton(
              day: 'S',
              isSelected: selectedDays.contains(7),
              onTap: () => _toggleDay(7),
            ),
            _DayButton(
              day: 'M',
              isSelected: selectedDays.contains(1),
              onTap: () => _toggleDay(1),
            ),
            _DayButton(
              day: 'T',
              isSelected: selectedDays.contains(2),
              onTap: () => _toggleDay(2),
            ),
            _DayButton(
              day: 'W',
              isSelected: selectedDays.contains(3),
              onTap: () => _toggleDay(3),
            ),
            _DayButton(
              day: 'T',
              isSelected: selectedDays.contains(4),
              onTap: () => _toggleDay(4),
            ),
            _DayButton(
              day: 'F',
              isSelected: selectedDays.contains(5),
              onTap: () => _toggleDay(5),
            ),
            _DayButton(
              day: 'S',
              isSelected: selectedDays.contains(6),
              onTap: () => _toggleDay(6),
            ),
          ],
        ),
      ],
    );
  }

  void _toggleDay(int day) {
    final currentDays = schedule.selectedDaysList;
    List<int> newDays;

    if (currentDays.contains(day)) {
      if (currentDays.length > 1) {
        newDays = currentDays.where((d) => d != day).toList()..sort();
      } else {
        return;
      }
    } else {
      newDays = [...currentDays, day]..sort();
    }

    onScheduleChanged(
        HabitSchedule(selectedDays: HabitSchedule.daysToString(newDays)));
  }
}

class _DayButton extends StatelessWidget {
  final String day;
  final bool isSelected;
  final VoidCallback onTap;

  const _DayButton({
    required this.day,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? CupertinoColors.white
              : CupertinoColors.darkBackgroundGray,
        ),
        child: Center(
          child: Text(
            day,
            style: TextStyle(
              color: isSelected
                  ? CupertinoColors.black
                  : CupertinoColors.systemGrey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
