import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:karman_app/models/task/task.dart';
import 'package:karman_app/controllers/task/task_controller.dart';
import 'package:provider/provider.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final Function(bool?)? onChanged;
  final Function(BuildContext)? onDelete;
  final VoidCallback onTap;

  const TaskTile({
    super.key,
    required this.task,
    required this.onChanged,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskController>(
      builder: (context, taskController, child) {
        bool isPendingCompletion =
            taskController.isTaskPendingCompletion(task.taskId!);
        bool isChecked = task.isCompleted || isPendingCompletion;

        return Material(
          color: Colors.transparent,
          child: Slidable(
            key: ValueKey(task.taskId),
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              children: [
                SlidableAction(
                  onPressed: onDelete,
                  backgroundColor: CupertinoColors.darkBackgroundGray,
                  foregroundColor: Colors.redAccent,
                  icon: CupertinoIcons.delete,
                  label: 'Delete',
                ),
              ],
            ),
            child: GestureDetector(
              onTap: onTap,
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
                              onChanged: onChanged,
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
                                task.name,
                                style: TextStyle(
                                  color: isChecked
                                      ? Colors.grey[700]
                                      : CupertinoColors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (_hasAdditionalInfo)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Row(
                                    children: [
                                      if (task.dueDate != null)
                                        _buildIcon(CupertinoIcons.calendar),
                                      if (task.reminder != null)
                                        _buildIcon(CupertinoIcons.clock),
                                      if (task.note != null &&
                                          task.note!.isNotEmpty)
                                        _buildIcon(CupertinoIcons.doc_text),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
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

  Widget _buildIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  bool get _hasAdditionalInfo =>
      task.dueDate != null ||
      task.reminder != null ||
      (task.note != null && task.note!.isNotEmpty);
}
