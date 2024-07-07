import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:karman_app/components/date_time/date_button.dart';
import 'package:karman_app/components/date_time/reminders.dart';
import 'package:karman_app/components/task/task_note.dart';
import 'package:karman_app/controllers/task/task_controller.dart';
import 'package:karman_app/models/task/task.dart';
import 'package:karman_app/services/notification_service.dart';
import 'package:provider/provider.dart';

class TaskDetailsSheet extends StatefulWidget {
  final Task task;

  const TaskDetailsSheet({
    super.key,
    required this.task,
  });

  @override
  _TaskDetailsSheetState createState() => _TaskDetailsSheetState();
}

class _TaskDetailsSheetState extends State<TaskDetailsSheet> {
  late TextEditingController _noteController;
  late DateTime? _dueDate;
  late int _priority;
  late DateTime? _reminder;
  bool _isDateEnabled = false;
  bool _isReminderEnabled = false;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.task.note);
    _dueDate = widget.task.dueDate;
    _priority = widget.task.priority;
    _reminder = widget.task.reminder;
    _isDateEnabled = widget.task.dueDate != null;
    _isReminderEnabled = widget.task.reminder != null;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final updatedTask = Task(
      taskId: widget.task.taskId,
      name: widget.task.name,
      note: _noteController.text,
      priority: _priority,
      dueDate: _isDateEnabled ? _dueDate : null,
      reminder: _isReminderEnabled ? _reminder : null,
      folderId: widget.task.folderId,
    );

    context.read<TaskController>().updateTask(updatedTask);

    if (updatedTask.reminder != null) {
      NotificationService.scheduleNotification(
        id: updatedTask.taskId!,
        title: 'Task Reminder',
        body: updatedTask.name,
        scheduledDate: updatedTask.reminder!,
        payload: 'task_${updatedTask.taskId}',
      );
    } else {
      NotificationService.cancelNotification(updatedTask.taskId!);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.2,
      maxChildSize: 0.9,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: CupertinoColors.darkBackgroundGray,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(20),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        widget.task.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: _saveChanges,
                        child: Icon(
                          CupertinoIcons.check_mark_circled,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TaskNote(
                          controller: _noteController,
                          hintText: 'Note...',
                        ),
                        SizedBox(height: 30),
                        _buildToggleRow(
                          icon: CupertinoIcons.calendar,
                          title: 'Date',
                          isEnabled: _isDateEnabled,
                          onToggle: (value) {
                            setState(() {
                              _isDateEnabled = value;
                              if (!value) _dueDate = null;
                            });
                          },
                          child: DateButton(
                            selectedDate: _dueDate,
                            onDateSelected: (date) {
                              setState(() {
                                _dueDate = date;
                              });
                            },
                            isEnabled: _isDateEnabled,
                          ),
                        ),
                        SizedBox(height: 20),
                        _buildToggleRow(
                          icon: CupertinoIcons.bell,
                          title: 'Reminder',
                          isEnabled: _isReminderEnabled,
                          onToggle: (value) {
                            setState(() {
                              _isReminderEnabled = value;
                              if (!value) _reminder = null;
                            });
                          },
                          child: ReminderButton(
                            selectedDateTime: _reminder,
                            onReminderSet: (DateTime newDateTime) {
                              setState(() {
                                _reminder = newDateTime;
                              });
                            },
                            isEnabled: _isReminderEnabled,
                          ),
                        ),
                        SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildPriorityOption(1, Colors.green),
                            _buildPriorityOption(2, Colors.yellow),
                            _buildPriorityOption(3, Colors.red),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required String title,
    required bool isEnabled,
    required Function(bool) onToggle,
    required Widget child,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.white),
        SizedBox(width: 10),
        Expanded(child: child),
        CupertinoSwitch(
          value: isEnabled,
          onChanged: onToggle,
          activeColor: Colors.white,
        ),
      ],
    );
  }

  Widget _buildPriorityOption(int priority, Color color) {
    bool isSelected = _priority == priority;
    return GestureDetector(
      onTap: () {
        setState(() {
          _priority = priority;
        });
      },
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? color : Colors.transparent,
              border: Border.all(
                color: isSelected ? color : Colors.white,
                width: 2,
              ),
            ),
            child: Center(
              child: Icon(
                CupertinoIcons.flag_fill,
                color: isSelected ? Colors.black : color,
                size: 20,
              ),
            ),
          ),
          SizedBox(height: 5),
          Text(
            priority == 1 ? 'Low' : (priority == 2 ? 'Medium' : 'High'),
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
