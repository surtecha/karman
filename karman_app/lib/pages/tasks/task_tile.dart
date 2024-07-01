import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class TaskTile extends StatelessWidget {
  final String taskName;
  final bool taskCompleted;
  final Function(bool?)? onChanged;
  final Function(BuildContext)? onEdit;
  final Function(BuildContext)? onDelete;
  final String priority;
  final DateTime? dueDate;
  final DateTime? reminderDate;
  final TimeOfDay? reminderTime;

  TaskTile({
    super.key,
    required this.taskName,
    required this.taskCompleted,
    required this.onChanged,
    required this.onEdit,
    required this.onDelete,
    required this.priority,
    this.dueDate,
    this.reminderDate,
    this.reminderTime,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Material(
        color: Colors.transparent,
        child: Slidable(
          key: ValueKey(taskName),
          endActionPane: ActionPane(
            motion: DrawerMotion(),
            children: [
              SlidableAction(
                onPressed: onEdit,
                backgroundColor: Colors.black,
                foregroundColor: Colors.blueAccent,
                icon: CupertinoIcons.pen,
                label: 'Edit',
              ),
              SlidableAction(
                onPressed: onDelete,
                backgroundColor: Colors.black,
                foregroundColor: Colors.redAccent,
                icon: CupertinoIcons.delete,
                label: 'Delete',
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: taskCompleted,
                onChanged: onChanged,
                checkColor: Colors.black,
                activeColor: Colors.white,
                shape: CircleBorder(),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey[800]!,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        taskName,
                        style: TextStyle(
                          color: taskCompleted
                              ? Colors.grey[700]
                              : Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          _buildPriorityIcon(),
                          SizedBox(width: 12),
                          if (dueDate != null) _buildDateIcon(),
                          if (dueDate != null) SizedBox(width: 12),
                          if (reminderDate != null && reminderTime != null)
                            _buildReminderIcon(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityIcon() {
    Color color;
    switch (priority.toLowerCase()) {
      case 'low':
        color = Colors.green;
        break;
      case 'medium':
        color = Colors.yellow;
        break;
      case 'high':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Icon(CupertinoIcons.flag_fill, color: color, size: 16);
  }

  Widget _buildDateIcon() {
    return Icon(CupertinoIcons.calendar, color: Colors.white, size: 16);
  }

  Widget _buildReminderIcon() {
    return Icon(CupertinoIcons.clock, color: Colors.white, size: 16);
  }
}
