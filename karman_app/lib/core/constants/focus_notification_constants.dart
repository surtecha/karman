import 'dart:math';

class FocusConstants {
  static const String endNotificationTitle = "Focus Session Complete";
  static final List<String> endNotificationBody = [
    "Great work! You've completed your focus session.",
    "Well done on staying focused!",
    "You've crushed it! Time for a break.",
    "Awesome job! Take pride in your productivity.",
    "Session complete. You should feel proud!",
  ];

  static String getRandomEndNotificationBody() {
    final random = Random();
    return endNotificationBody[random.nextInt(endNotificationBody.length)];
  }
}
