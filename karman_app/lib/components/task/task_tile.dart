import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:karman_app/models/task/task.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final Function(bool?)? onChanged;
  final Function(BuildContext)? onEdit;
  final Function(BuildContext)? onDelete;

  const TaskTile({
    Key? key,
    required this.task,
    required this.onChanged,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Material(
        color: Colors.transparent,
        child: Slidable(
          key: ValueKey(task.taskId),
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
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
                value: task.isCompleted,
                onChanged: onChanged,
                checkColor: Colors.black,
                activeColor: Colors.white,
                shape: const CircleBorder(),
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
                        task.name,
                        style: TextStyle(
                          color: task.isCompleted
                              ? Colors.grey[700]
                              : Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildPriorityIcon(),
                          const SizedBox(width: 12),
                          if (task.dueDate != null) _buildDateIcon(),
                          if (task.dueDate != null) const SizedBox(width: 12),
                          if (task.reminder != null) _buildReminderIcon(),
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
    switch (task.priority) {
      case 1:
        color = Colors.green;
        break;
      case 2:
        color = Colors.yellow;
        break;
      case 3:
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Icon(CupertinoIcons.flag_fill, color: color, size: 16);
  }

  Widget _buildDateIcon() {
    return const Icon(CupertinoIcons.calendar, color: Colors.white, size: 16);
  }

  Widget _buildReminderIcon() {
    return const Icon(CupertinoIcons.clock, color: Colors.white, size: 16);
  }
}
