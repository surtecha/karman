import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'notification_navigation_service.dart';

class BaseNotificationService {
  static final BaseNotificationService _instance =
      BaseNotificationService._internal();
  factory BaseNotificationService() => _instance;
  BaseNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final NotificationNavigationService _navigation =
      NotificationNavigationService();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _notifications.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: (details) {
        _navigation.handleNotificationTap(details.payload);
      },
    );
    await _createNotificationChannels();
    _initialized = true;
  }

  Future<void> _createNotificationChannels() async {
    const todoChannel = AndroidNotificationChannel(
      'todo_high_priority',
      'Todo Reminders',
      description: 'High priority notifications for todos and overdue alerts',
      importance: Importance.high,
      enableVibration: true,
    );

    const habitChannel = AndroidNotificationChannel(
      'habit_reminders',
      'Habit Reminders',
      description: 'Daily habit reminders and streak warnings',
      importance: Importance.defaultImportance,
      enableVibration: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(todoChannel);
    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(habitChannel);
  }

  Future<bool> requestPermissions() async {
    final iosImpl =
        _notifications
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
    final androidImpl =
        _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    final iosGranted =
        await iosImpl?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        true;
    final androidGranted =
        await androidImpl?.requestNotificationsPermission() ?? true;

    if (androidImpl != null) {
      final canSchedule =
          await androidImpl.canScheduleExactNotifications() ?? false;
      if (!canSchedule) {
        await androidImpl.requestExactAlarmsPermission();
      }
    }

    return iosGranted && androidGranted;
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? channelId,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId ?? 'todo_high_priority',
      channelId == 'habit_reminders' ? 'Habit Reminders' : 'Todo Reminders',
      importance:
          channelId == 'habit_reminders'
              ? Importance.defaultImportance
              : Importance.high,
      priority: Priority.high,
      showWhen: true,
      visibility: NotificationVisibility.public,
      enableLights: true,
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _notifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      payload: payload,
    );
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? channelId,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId ?? 'todo_high_priority',
      channelId == 'habit_reminders' ? 'Habit Reminders' : 'Todo Reminders',
      importance:
          channelId == 'habit_reminders'
              ? Importance.defaultImportance
              : Importance.high,
      priority: Priority.high,
      showWhen: true,
      visibility: NotificationVisibility.public,
      enableLights: true,
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _notifications.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id: id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
