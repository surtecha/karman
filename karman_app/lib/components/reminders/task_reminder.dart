import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class TaskReminder extends StatefulWidget {
  final bool isEnabled;
  final DateTime? dateTime;
  final Function(bool) onToggle;
  final Function(DateTime?) onDateTimeSelected;
  final String title;
  final String placeholder;

  const TaskReminder({
    super.key,
    required this.isEnabled,
    required this.dateTime,
    required this.onToggle,
    required this.onDateTimeSelected,
    required this.title,
    required this.placeholder,
  });

  @override
  TaskReminderState createState() => TaskReminderState();
}

class TaskReminderState extends State<TaskReminder>
    with SingleTickerProviderStateMixin {
  bool isPickerVisible = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  DateTime? _selectedDateTime;
  bool _wasDateTimeSelected = false;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = widget.dateTime ?? _getInitialDateTime();
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

  @override
  void didUpdateWidget(TaskReminder oldWidget) {
    if (oldWidget.dateTime != widget.dateTime && widget.dateTime != null) {
      if (!_wasDateTimeSelected) _selectedDateTime = widget.dateTime;
    }
    super.didUpdateWidget(oldWidget);
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

  void _handleDateTimeSelection(DateTime dateTime) {
    setState(() {
      _selectedDateTime = dateTime;
      _wasDateTimeSelected = true;
    });
    widget.onDateTimeSelected(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildToggleRow(),
        SizeTransition(
          sizeFactor: _animation,
          child: isPickerVisible
              ? _buildDateTimePicker()
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildToggleRow() {
    return Row(
      children: [
        const Icon(CupertinoIcons.bell, color: CupertinoColors.white),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (widget.isEnabled) {
                _togglePicker(true);
              }
            },
            child: Text(
              widget.isEnabled && _selectedDateTime != null
                  ? DateFormat('MMM d, yyyy HH:mm').format(_selectedDateTime!)
                  : widget.placeholder,
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

  Widget _buildDateTimePicker() {
    final minimumDate = _getInitialDateTime();
    return SizedBox(
      height: 220,
      child: Column(
        children: [
          Expanded(
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.dateAndTime,
              initialDateTime: _selectedDateTime!.isAfter(minimumDate)
                  ? _selectedDateTime
                  : minimumDate,
              minimumDate: minimumDate,
              onDateTimeChanged: _handleDateTimeSelection,
            ),
          ),
          CupertinoButton(
            child: const Text(
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

  DateTime _getInitialDateTime() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, now.hour, now.minute + 1);
  }
}
