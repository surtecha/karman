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
  final Task? task;
  final bool isNewTask;

  const TaskDetailsSheet({
    Key? key,
    this.task,
    required this.isNewTask,
  }) : super(key: key);

  @override
  _TaskDetailsSheetState createState() => _TaskDetailsSheetState();
}

class _TaskDetailsSheetState extends State<TaskDetailsSheet> {
  late TextEditingController _nameController;
  late TextEditingController _noteController;
  late DateTime? _dueDate;
  late int _priority;
  late DateTime? _reminder;
  bool _isDateEnabled = false;
  bool _isReminderEnabled = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.task?.name ?? '');
    _noteController = TextEditingController(text: widget.task?.note ?? '');
    _dueDate = widget.task?.dueDate;
    _priority = widget.task?.priority ?? 1;
    _reminder = widget.task?.reminder;
    _isDateEnabled = widget.task?.dueDate != null;
    _isReminderEnabled = widget.task?.reminder != null;

    if (widget.isNewTask) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(_nameFocusNode);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  final FocusNode _nameFocusNode = FocusNode();

  bool _isDateInPast(DateTime date) {
    final now = DateTime.now();
    return date.isBefore(now);
  }

  void _saveChanges() {
    if (_nameController.text.trim().isEmpty) {
      _showQuirkyDialog('A Task Without a Name?',
          'Your task is feeling a bit shy and nameless. How about giving it a snazzy title to boost its confidence?');
      return;
    }

    if (_isReminderEnabled && _reminder != null && _isDateInPast(_reminder!)) {
      _showQuirkyDialog('Time Travel Not Invented Yet!',
          'Unless you have a time machine, we can\'t remind you in the past.');
      return;
    }

    final updatedTask = Task(
      taskId: widget.task?.taskId,
      name: _nameController.text.trim(),
      note: _noteController.text,
      priority: _priority,
      dueDate: _isDateEnabled ? _dueDate : null,
      reminder: _isReminderEnabled ? _reminder : null,
      isCompleted: widget.task?.isCompleted ?? false,
    );

    if (widget.isNewTask) {
      context.read<TaskController>().addTask(updatedTask);
    } else {
      context.read<TaskController>().updateTask(updatedTask);
    }

    if (updatedTask.reminder != null) {
      NotificationService.scheduleNotification(
        id: updatedTask.taskId!,
        title: 'Task Reminder',
        body: updatedTask.name,
        scheduledDate: updatedTask.reminder!,
        payload: 'task_${updatedTask.taskId}',
      );
    } else if (updatedTask.taskId != null) {
      NotificationService.cancelNotification(updatedTask.taskId!);
    }

    Navigator.of(context).pop(true);
  }

  void _showQuirkyDialog(String title, String content) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title, style: TextStyle(fontSize: 18)),
        content: Text(content),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            child: Text('Got it!'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.2,
        maxChildSize: 0.9,
        builder: (BuildContext context, ScrollController scrollController) {
          return GestureDetector(
            onTap: () {},
            child: Container(
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
                    child: Row(
                      children: [
                        Expanded(
                          child: CupertinoTextField(
                            controller: _nameController,
                            focusNode: _nameFocusNode,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                            placeholder: 'Task Name',
                            placeholderStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 24,
                            ),
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: _saveChanges,
                          child: Icon(
                            CupertinoIcons.check_mark_circled,
                            color: Colors.white,
                            size: 30,
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
            ),
          );
        },
      ),
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
