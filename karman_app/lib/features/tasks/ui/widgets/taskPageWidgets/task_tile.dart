import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:karman_app/features/tasks/data/task.dart';
import 'package:karman_app/features/tasks/logic/task_controller.dart';
import 'package:provider/provider.dart';

class TaskTile extends StatefulWidget {
  final Task task;
  final Function(bool?)? onChanged;
  final Function(BuildContext)? onDelete;
  final VoidCallback onTap;
  final bool showReorderIcon;

  const TaskTile({
    super.key,
    required this.task,
    required this.onChanged,
    required this.onDelete,
    required this.onTap,
    this.showReorderIcon = true,
  });

  @override
  TaskTileState createState() => TaskTileState();
}

class TaskTileState extends State<TaskTile> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduleUpdates();
    });
  }

  void _scheduleUpdates() {
    final taskController = Provider.of<TaskController>(context, listen: false);
    if (widget.task.dueDate != null) {
      taskController.scheduleUpdate(widget.task.taskId!, widget.task.dueDate!);
    }
    if (widget.task.reminder != null) {
      taskController.scheduleUpdate(widget.task.taskId!, widget.task.reminder!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskController>(
      builder: (context, taskController, child) {
        bool isPendingCompletion =
            taskController.isTaskPendingCompletion(widget.task.taskId!);
        bool isChecked = widget.task.isCompleted || isPendingCompletion;

        return Material(
          color: Colors.transparent,
          child: Slidable(
            key: ValueKey(widget.task.taskId),
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              children: [
                SlidableAction(
                  onPressed: widget.onDelete,
                  backgroundColor: CupertinoColors.darkBackgroundGray,
                  foregroundColor: CupertinoColors.systemRed,
                  icon: CupertinoIcons.delete,
                  label: 'Delete',
                ),
              ],
            ),
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border(
                    bottom: BorderSide(
                      color: CupertinoColors.darkBackgroundGray,
                      width: 1,
                    ),
                  ),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 60,
                        child: Center(
                          child: Transform.scale(
                            scale: 1.3,
                            child: Checkbox(
                              value: isChecked,
                              onChanged: widget.onChanged,
                              checkColor: CupertinoColors.black,
                              activeColor: CupertinoColors.white,
                              shape: const CircleBorder(),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.task.name,
                                style: TextStyle(
                                  color: isChecked
                                      ? Colors.grey[700]
                                      : CupertinoColors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  if (widget.task.dueDate != null)
                                    _buildInfoWithIcon(
                                      CupertinoIcons.calendar,
                                      _formatDate(widget.task.dueDate!),
                                      isOverdue:
                                          _isOverdue(widget.task.dueDate!),
                                    ),
                                  widget.task.dueDate != null
                                      ? SizedBox(width: 20)
                                      : SizedBox(width: 0),
                                  if (widget.task.reminder != null)
                                    _buildInfoWithIcon(
                                      CupertinoIcons.bell_fill,
                                      _formatDateTime(widget.task.reminder!),
                                      isOverdue:
                                          _isOverdue(widget.task.reminder!),
                                    ),
                                  widget.task.reminder != null
                                      ? SizedBox(width: 20)
                                      : SizedBox(width: 0),
                                  if (widget.task.note != null &&
                                      widget.task.note!.isNotEmpty)
                                    Icon(
                                      CupertinoIcons.doc_text_fill,
                                      size: 16,
                                      color: widget.task.isCompleted
                                          ? Colors.grey[700]
                                          : CupertinoColors.systemGrey5,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (widget.showReorderIcon) ...[
                        SizedBox(width: 16),
                        Icon(
                          CupertinoIcons.line_horizontal_3,
                          color: CupertinoColors.systemGrey,
                        ),
                        SizedBox(width: 16),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoWithIcon(IconData icon, String text,
      {bool isOverdue = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: isOverdue
              ? CupertinoColors.systemRed
              : (widget.task.isCompleted
                  ? Colors.grey[700]
                  : CupertinoColors.systemGrey5),
        ),
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: isOverdue
                ? CupertinoColors.systemRed
                : (widget.task.isCompleted
                    ? Colors.grey[700]
                    : CupertinoColors.systemGrey5),
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d').format(date);
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, h:mm a').format(dateTime);
  }

  bool _isOverdue(DateTime date) {
    return date.isBefore(DateTime.now()) && !widget.task.isCompleted;
  }
}
