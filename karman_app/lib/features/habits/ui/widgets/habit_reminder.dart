import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HabitReminder extends StatefulWidget {
  final bool isEnabled;
  final TimeOfDay? time;
  final Function(bool) onToggle;
  final Function(TimeOfDay) onTimeSelected;

  const HabitReminder({
    super.key,
    required this.isEnabled,
    required this.time,
    required this.onToggle,
    required this.onTimeSelected,
  });

  @override
  _HabitReminderState createState() => _HabitReminderState();
}

class _HabitReminderState extends State<HabitReminder>
    with SingleTickerProviderStateMixin {
  bool isPickerVisible = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _togglePicker(bool value) {
    widget.onToggle(value);
    if (value) {
      setState(() {
        isPickerVisible = true;
      });
      _animationController.forward();
    } else {
      _animationController.reverse().then((_) {
        setState(() {
          isPickerVisible = false;
        });
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour =
        time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildToggleRow(),
        SizeTransition(
          sizeFactor: _animation,
          child: isPickerVisible ? _buildTimePicker() : SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildToggleRow() {
    return Row(
      children: [
        Icon(CupertinoIcons.bell, color: CupertinoColors.white),
        SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (widget.isEnabled) {
                _togglePicker(true);
              }
            },
            child: Text(
              widget.time == null
                  ? 'Set daily reminder'
                  : _formatTime(widget.time!),
              style: TextStyle(
                color: widget.isEnabled
                    ? CupertinoColors.white
                    : CupertinoColors.systemGrey,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        CupertinoSwitch(
          value: widget.isEnabled,
          onChanged: _togglePicker,
          thumbColor: CupertinoColors.black,
          activeColor: CupertinoColors.white,
          trackColor: CupertinoColors.tertiaryLabel,
        ),
      ],
    );
  }

  Widget _buildTimePicker() {
    DateTime initialTime;
    if (widget.time != null) {
      final now = DateTime.now();
      initialTime = DateTime(
          now.year, now.month, now.day, widget.time!.hour, widget.time!.minute);
    } else {
      initialTime = DateTime.now().add(Duration(minutes: 1));
    }

    return SizedBox(
      height: 220,
      child: Column(
        children: [
          Expanded(
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.time,
              initialDateTime: initialTime,
              onDateTimeChanged: (DateTime dateTime) {
                widget.onTimeSelected(TimeOfDay.fromDateTime(dateTime));
              },
              use24hFormat: true,
            ),
          ),
          CupertinoButton(
            child: Text(
              'Done',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: CupertinoColors.white,
              ),
            ),
            onPressed: () {
              _animationController.reverse().then((_) {
                setState(() {
                  isPickerVisible = false;
                });
              });
            },
          ),
        ],
      ),
    );
  }
}
