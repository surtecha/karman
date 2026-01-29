import '../../models/todo.dart';
import 'base_notification_service.dart';

class TodoNotificationService {
  static final TodoNotificationService _instance =
      TodoNotificationService._internal();
  factory TodoNotificationService() => _instance;
  TodoNotificationService._internal();

  final BaseNotificationService _base = BaseNotificationService();

  int _getInitialNotificationId(int todoId) => 1000 + todoId;
  int _getOverdueNotificationId(int todoId, int iteration) =>
      2000 + (todoId * 100) + iteration;

  Future<void> scheduleTodoNotifications(Todo todo) async {
    if (todo.id == null || todo.reminder == null) return;

    await cancelTodoNotifications(todo.id!);

    final now = DateTime.now();
    if (todo.reminder!.isAfter(now)) {
      await _base.scheduleNotification(
        id: _getInitialNotificationId(todo.id!),
        title: todo.name,
        body: 'Today, ${_formatTime(todo.reminder!)}',
        scheduledDate: todo.reminder!,
        payload: 'todo_${todo.id}',
      );

      await _scheduleOverdueNotifications(todo);
    }
  }

  Future<void> _scheduleOverdueNotifications(Todo todo) async {
    if (todo.reminder == null) return;

    final firstOverdue = todo.reminder!.add(const Duration(hours: 6));
    final now = DateTime.now();

    for (int i = 0; i < 8; i++) {
      final overdueTime = firstOverdue.add(Duration(hours: i * 6));
      if (overdueTime.isAfter(now)) {
        await _base.scheduleNotification(
          id: _getOverdueNotificationId(todo.id!, i),
          title: todo.name,
          body: 'Still pending',
          scheduledDate: overdueTime,
          payload: 'todo_overdue_${todo.id}',
        );
      }
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute$period';
  }

  Future<void> cancelTodoNotifications(int todoId) async {
    await _base.cancelNotification(_getInitialNotificationId(todoId));

    for (int i = 0; i < 8; i++) {
      await _base.cancelNotification(_getOverdueNotificationId(todoId, i));
    }
  }

  Future<void> rescheduleRepeatingTodo(Todo todo) async {
    if (!todo.isRepeating || todo.reminder == null) return;

    await scheduleTodoNotifications(todo);
  }

  Future<void> handleTodoCompletion(int todoId) async {
    await cancelTodoNotifications(todoId);
  }

  Future<void> handleTodoDeletion(int todoId) async {
    await cancelTodoNotifications(todoId);
  }
}
