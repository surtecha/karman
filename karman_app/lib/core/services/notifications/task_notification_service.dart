import 'package:karman_app/core/services/notifications/notification_service.dart';
import 'package:karman_app/features/tasks/data/task.dart';

class TaskNotificationService {
  static Future<void> scheduleNotification(Task task) async {
    if (task.reminder != null && task.taskId != null && !task.isCompleted) {
      await NotificationService.scheduleNotification(
        id: task.taskId!,
        title: 'To-Do Reminder',
        body: task.name,
        scheduledDate: task.reminder!,
        payload: _generateTaskPayload(task.taskId!),
      );
    }
  }

  static Future<void> cancelNotification(int taskId) async {
    await NotificationService.cancelNotification(taskId);
  }

  static Future<void> updateNotification(Task task) async {
    await cancelNotification(task.taskId!);
    await scheduleNotification(task);
  }

  static String _generateTaskPayload(int taskId) {
    return 'task_$taskId';
  }
}
