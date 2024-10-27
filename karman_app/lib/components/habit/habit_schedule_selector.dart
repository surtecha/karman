import 'package:flutter/cupertino.dart';
import 'package:karman_app/models/habits/habit_schedule.dart';

class HabitScheduleSelector extends StatefulWidget {
  final HabitSchedule schedule;
  final Function(HabitSchedule) onScheduleChanged;

  const HabitScheduleSelector({
    super.key,
    required this.schedule,
    required this.onScheduleChanged,
  });

  @override
  HabitScheduleSelectorState createState() => HabitScheduleSelectorState();
}

class HabitScheduleSelectorState extends State<HabitScheduleSelector>
    with SingleTickerProviderStateMixin {
  bool isScheduleVisible = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final List<int> allDays = [1, 2, 3, 4, 5, 6, 7];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    );

    final selectedDays = widget.schedule.selectedDaysList;
    isScheduleVisible = selectedDays.isNotEmpty && selectedDays.length < 7;
    if (isScheduleVisible) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool get _isCustomSchedule {
    final selectedDays = widget.schedule.selectedDaysList;
    return selectedDays.isNotEmpty && selectedDays.length < 7;
  }

  void _toggleSchedule(bool value) {
    setState(() {
      if (value) {
        isScheduleVisible = true;
        _animationController.forward();
        widget.onScheduleChanged(
          HabitSchedule(
              selectedDays: HabitSchedule.daysToString([1, 2, 3, 4, 5])),
        );
      } else {
        _animationController.reverse().then((_) {
          isScheduleVisible = false;
          widget.onScheduleChanged(
            HabitSchedule(selectedDays: HabitSchedule.daysToString(allDays)),
          );
        });
      }
    });
  }

  void _toggleDay(int day) {
    final currentDays = widget.schedule.selectedDaysList;
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

    if (newDays.length == 7) {
      _toggleSchedule(false);
      return;
    }

    widget.onScheduleChanged(
      HabitSchedule(selectedDays: HabitSchedule.daysToString(newDays)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildToggleRow(),
        SizeTransition(
          sizeFactor: _animation,
          child:
              isScheduleVisible ? _buildDaySelector() : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildToggleRow() {
    return Row(
      children: [
        Icon(
          CupertinoIcons.repeat,
          color: _isCustomSchedule
              ? CupertinoColors.white
              : CupertinoColors.systemGrey,
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Custom repeat',
            style: TextStyle(
              color: _isCustomSchedule
                  ? CupertinoColors.white
                  : CupertinoColors.systemGrey,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        CupertinoSwitch(
          value: _isCustomSchedule,
          onChanged: _toggleSchedule,
          thumbColor: CupertinoColors.black,
          activeColor: CupertinoColors.white,
          trackColor: CupertinoColors.tertiaryLabel,
        ),
      ],
    );
  }

  Widget _buildDaySelector() {
    final selectedDays = widget.schedule.selectedDaysList;

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
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
    );
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
          border: !isSelected
              ? Border.all(color: CupertinoColors.systemGrey, width: 1)
              : null,
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
