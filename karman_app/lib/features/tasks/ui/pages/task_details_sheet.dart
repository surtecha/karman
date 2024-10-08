import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:karman_app/core/services/notifications/task_notification_service.dart';
import 'package:karman_app/features/tasks/data/task.dart';
import 'package:karman_app/features/tasks/logic/task_controller.dart';
import 'package:karman_app/features/tasks/ui/widgets/taskDetailsWidgets/priority_selector.dart';
import 'package:karman_app/features/tasks/ui/widgets/taskDetailsWidgets/task_name_input.dart';
import 'package:karman_app/features/tasks/ui/widgets/taskDetailsWidgets/task_note.dart';
import 'package:karman_app/features/tasks/ui/widgets/taskDetailsWidgets/task_options_section.dart';
import 'package:provider/provider.dart';

class TaskDetailsSheet extends StatefulWidget {
  final Task? task;
  final bool isNewTask;

  const TaskDetailsSheet({
    super.key,
    this.task,
    required this.isNewTask,
  });

  @override
  TaskDetailsSheetState createState() => TaskDetailsSheetState();
}

class TaskDetailsSheetState extends State<TaskDetailsSheet> {
  late TextEditingController _nameController;
  late TextEditingController _noteController;
  late DateTime? _dueDate;
  late int _priority;
  late DateTime? _reminder;
  bool _isDateEnabled = false;
  bool _isReminderEnabled = false;
  bool _isTaskNameEmpty = true;
  bool _hasChanges = false;
  late FocusNode _nameFocusNode;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupListeners();
    _nameFocusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isNewTask) {
        _nameFocusNode.requestFocus();
      }
    });
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.task?.name ?? '');
    _noteController = TextEditingController(text: widget.task?.note ?? '');
    _dueDate = widget.task?.dueDate;
    _priority = widget.task?.priority ?? 1;
    _reminder = widget.task?.reminder;
    _isDateEnabled = widget.task?.dueDate != null;
    _isReminderEnabled = widget.task?.reminder != null;
    _isTaskNameEmpty = _nameController.text.trim().isEmpty;
    _hasChanges = widget.isNewTask;
  }

  void _setupListeners() {
    _nameController.addListener(_checkForChanges);
    _noteController.addListener(_checkForChanges);
  }

  @override
  void dispose() {
    _nameController.removeListener(_checkForChanges);
    _noteController.removeListener(_checkForChanges);
    _nameController.dispose();
    _noteController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  void _checkForChanges() {
    setState(() {
      _hasChanges = _hasChangesOccurred();
      _isTaskNameEmpty = _nameController.text.trim().isEmpty;
    });
  }

  bool _hasChangesOccurred() {
    return widget.isNewTask ||
        _nameController.text != (widget.task?.name ?? '') ||
        _noteController.text != (widget.task?.note ?? '') ||
        _dueDate != widget.task?.dueDate ||
        _priority != (widget.task?.priority ?? 1) ||
        _reminder != widget.task?.reminder ||
        _isDateEnabled != (widget.task?.dueDate != null) ||
        _isReminderEnabled != (widget.task?.reminder != null);
  }

  void _saveChanges() async {
    final updatedTask = _createUpdatedTask();
    final savedTask = await _saveTaskToController(updatedTask);
    await _handleNotification(savedTask);
    Navigator.of(context).pop(true);
  }

  Task _createUpdatedTask() {
    return Task(
      taskId: widget.task?.taskId,
      name: _nameController.text.trim(),
      note: _noteController.text,
      priority: _priority,
      dueDate: _isDateEnabled ? _dueDate : null,
      reminder: _isReminderEnabled ? _reminder : null,
      isCompleted: widget.task?.isCompleted ?? false,
      order: widget.task?.order ?? 0,
    );
  }

  Future<Task> _saveTaskToController(Task task) async {
    if (widget.isNewTask) {
      return await context.read<TaskController>().addTask(task);
    } else {
      return await context.read<TaskController>().updateTask(task);
    }
  }

  Future<void> _handleNotification(Task task) async {
    if (task.reminder != null && task.taskId != null) {
      await TaskNotificationService.scheduleNotification(task);
    } else if (task.taskId != null) {
      await TaskNotificationService.cancelNotification(task.taskId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 40,
            left: 20,
            right: 20,
            top: 20,
          ),
          decoration: BoxDecoration(
            color: CupertinoColors.darkBackgroundGray,
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TaskNameInput(
                  controller: _nameController,
                  focusNode: _nameFocusNode,
                  onSave:
                      _hasChanges && !_isTaskNameEmpty ? _saveChanges : null,
                  isTaskNameEmpty: _isTaskNameEmpty,
                  hasChanges: _hasChanges,
                ),
                SizedBox(height: 20),
                TaskNote(
                  controller: _noteController,
                  hintText: 'Note...',
                ),
                SizedBox(height: 30),
                TaskOptionsSection(
                  isDateEnabled: _isDateEnabled,
                  isReminderEnabled: _isReminderEnabled,
                  dueDate: _dueDate,
                  reminder: _reminder,
                  onDateToggle: (value) => setState(() {
                    _isDateEnabled = value;
                    if (!value) _dueDate = null;
                    _checkForChanges();
                  }),
                  onReminderToggle: (value) => setState(() {
                    _isReminderEnabled = value;
                    if (!value) _reminder = null;
                    _checkForChanges();
                  }),
                  onDateSelected: (date) => setState(() {
                    _dueDate = date;
                    _checkForChanges();
                  }),
                  onReminderSet: (DateTime? newDateTime) => setState(() {
                    _reminder = newDateTime;
                    _checkForChanges();
                  }),
                ),
                SizedBox(height: 30),
                PrioritySelector(
                  selectedPriority: _priority,
                  onPriorityChanged: (priority) => setState(() {
                    _priority = priority;
                    _checkForChanges();
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
