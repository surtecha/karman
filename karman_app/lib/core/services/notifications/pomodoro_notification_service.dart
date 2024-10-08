import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PomodoroNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static const int _notificationId = 0;
  static const String _channelId = 'pomodoro_timer_channel';
  static const String _channelName = 'Pomodoro Timer';
  static const String _channelDescription =
      'Shows the current Pomodoro timer status';

  static Future<void> initialize() async {
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notifications.initialize(initializationSettings);
  }

  static Future<void> showPomodoroNotification({
    required String title,
    required String body,
    required int durationSeconds,
  }) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      ongoing: true,
      autoCancel: false,
      usesChronometer: true,
      chronometerCountDown: true,
      when: DateTime.now().millisecondsSinceEpoch + durationSeconds * 1000,
    );

    final DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _notifications.show(
      _notificationId,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  static Future<void> cancelNotification() async {
    await _notifications.cancel(_notificationId);
  }
}
