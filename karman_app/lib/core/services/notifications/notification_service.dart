import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:karman_app/app_shell.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static late GlobalKey<NavigatorState> navigatorKey;

  static Future<void> init(GlobalKey<NavigatorState> key) async {
    navigatorKey = key;
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/notification_icon');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (payload != null) {
      if (payload.startsWith('task_')) {
        navigateToTasksPage();
      } else if (payload.startsWith('habit_')) {
        navigateToHabitsPage();
      }
    }
  }

  static void navigateToTasksPage() {
    _navigateToPage(1);
  }

  static void navigateToHabitsPage() {
    _navigateToPage(0);
  }

  static void _navigateToPage(int tabIndex) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      Future.delayed(Duration(milliseconds: 100), () {
        final appShellState = AppShell.globalKey.currentState;
        if (appShellState != null) {
          appShellState.switchToTab(tabIndex);
        }
      });
    }
  }

  static Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        'instant_notification_channel',
        'Instant Notifications',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@drawable/notification_icon',
        color: Color.fromARGB(255, 255, 255, 255),
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
        styleInformation: BigTextStyleInformation(''),
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _notifications.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    tz.TZDateTime notificationTime = _nextInstanceOfTime(scheduledDate);

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      notificationTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'scheduled_notification_channel',
          'Scheduled Notifications',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@drawable/notification_icon',
          color: Color.fromARGB(255, 255, 255, 255),
          largeIcon: DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
          styleInformation: BigTextStyleInformation(''),
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  static tz.TZDateTime _nextInstanceOfTime(DateTime scheduledDate) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledTZDateTime =
        tz.TZDateTime.from(scheduledDate, tz.local);

    if (scheduledTZDateTime.isBefore(now)) {
      scheduledTZDateTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        scheduledDate.hour,
        scheduledDate.minute,
      );

      if (scheduledTZDateTime.isBefore(now)) {
        scheduledTZDateTime = scheduledTZDateTime.add(const Duration(days: 1));
      }
    }

    return scheduledTZDateTime;
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  static Future<void> scheduleStreakReminder({
    required int id,
    required String habitName,
    required int currentStreak,
    required DateTime scheduledDate,
  }) async {
    String title = "Don't break your streak!";
    String body =
        "Your $habitName streak is at $currentStreak days. Complete it now to keep it going!";

    if (currentStreak >= 7) {
      body =
          "🔥 $currentStreak day streak for $habitName! Don't let it slip away now!";
    } else if (currentStreak >= 30) {
      body =
          "🏆 Incredible $currentStreak day streak for $habitName! You've come too far to stop now!";
    }

    await scheduleNotification(
      id: id + 10000,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      payload: 'habit_$id',
    );
  }
}
