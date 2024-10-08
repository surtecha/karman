import 'package:flutter/cupertino.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class DateOptionWidget extends StatefulWidget {
  final bool isEnabled;
  final DateTime? date;
  final Function(bool) onToggle;
  final Function(DateTime?) onDateSelected;
  final String title;
  final String placeholder;

  const DateOptionWidget({
    super.key,
    required this.isEnabled,
    required this.date,
    required this.onToggle,
    required this.onDateSelected,
    required this.title,
    required this.placeholder,
  });

  @override
  DateOptionWidgetState createState() => DateOptionWidgetState();
}

class DateOptionWidgetState extends State<DateOptionWidget>
    with SingleTickerProviderStateMixin {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  bool isPickerVisible = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.date ?? DateTime.now();
    _selectedDay = widget.date;
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

  bool _isDateInPast(DateTime date) {
    final now = DateTime.now();
    return date.isBefore(DateTime(now.year, now.month, now.day));
  }

  void _handleDateSelection(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    widget.onDateSelected(selectedDay);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildToggleRow(),
        SizeTransition(
          sizeFactor: _animation,
          child: isPickerVisible
              ? _buildCalendarPicker()
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildToggleRow() {
    return Row(
      children: [
        const Icon(CupertinoIcons.calendar, color: CupertinoColors.white),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (widget.isEnabled) {
                _togglePicker(true);
              }
            },
            child: Text(
              widget.date == null
                  ? widget.placeholder
                  : DateFormat('MMM d, yyyy').format(widget.date!),
              style: TextStyle(
                color: widget.isEnabled
                    ? (widget.date != null && _isDateInPast(widget.date!)
                        ? CupertinoColors.systemRed
                        : CupertinoColors.white)
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

  Widget _buildCalendarPicker() {
    return Container(
      color: CupertinoColors.darkBackgroundGray,
      child: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 365 * 10)),
            focusedDay: _focusedDay,
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _handleDateSelection,
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            daysOfWeekHeight: 50,
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              weekendTextStyle: const TextStyle(color: CupertinoColors.white),
              holidayTextStyle: const TextStyle(color: CupertinoColors.white),
              defaultTextStyle: const TextStyle(color: CupertinoColors.white),
              todayTextStyle: const TextStyle(
                  color: CupertinoColors.black, fontWeight: FontWeight.bold),
              selectedTextStyle: const TextStyle(
                  color: CupertinoColors.black, fontWeight: FontWeight.bold),
              todayDecoration: BoxDecoration(
                color: CupertinoColors.white.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: CupertinoColors.white,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle:
                  TextStyle(color: CupertinoColors.white, fontSize: 17),
              leftChevronIcon: Icon(CupertinoIcons.left_chevron,
                  color: CupertinoColors.white),
              rightChevronIcon: Icon(CupertinoIcons.right_chevron,
                  color: CupertinoColors.white),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: CupertinoColors.white),
              weekendStyle: TextStyle(color: CupertinoColors.white),
            ),
          ),
          CupertinoButton(
            child: const Text(
              'Done',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: CupertinoColors.white),
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
