import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:karman_app/controllers/task/task_controller.dart';
import 'package:karman_app/models/task/task.dart';

class CompletedTasksHeader extends StatelessWidget {
  final int currentFolderId;

  const CompletedTasksHeader({super.key, required this.currentFolderId});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskController>(
      builder: (context, taskController, child) {
        final tasks = taskController.tasks
            .where((task) => task.folderId == currentFolderId)
            .toList();
        final completedTasks = tasks.where((task) => task.isCompleted).toList();
        final completedCount = completedTasks.length;
        final isActive = completedCount > 0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$completedCount Completed',
                style: TextStyle(
                  color: isActive
                      ? CupertinoColors.white
                      : CupertinoColors.systemGrey,
                  fontSize: 14,
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: isActive
                    ? () => _showClearConfirmation(
                        context, taskController, completedTasks)
                    : null,
                child: Text(
                  'Clear',
                  style: TextStyle(
                    color: isActive
                        ? CupertinoColors.white
                        : CupertinoColors.systemGrey,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showClearConfirmation(BuildContext context,
      TaskController taskController, List<Task> completedTasks) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          content: Text(
            'Clear all completed tasks?',
            style: TextStyle(
              color: CupertinoColors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                for (var task in completedTasks) {
                  taskController.deleteTask(task.taskId!);
                }
                Navigator.of(context).pop();
              },
              child: Text('Clear'),
            ),
          ],
        );
      },
    );
  }
}
