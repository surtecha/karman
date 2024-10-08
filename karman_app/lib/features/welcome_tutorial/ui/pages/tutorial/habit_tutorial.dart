import 'package:flutter/cupertino.dart';
import 'tutorial_overlay.dart';

class HabitsTutorial {
  static List<TutorialPage> pages = [
    TutorialPage(
      instruction: 'Create new habits',
      imageAsset: 'lib/assets/tutorials/habits/create_habit.png',
    ),
    TutorialPage(
      instruction: 'Tap the circle to complete',
      imageAsset: 'lib/assets/tutorials/habits/complete_habit.png',
    ),
    TutorialPage(
      instruction: 'Log your daily routine',
      imageAsset: 'lib/assets/tutorials/habits/log_routine.png',
    ),
    TutorialPage(
      instruction: 'Swipe right to complete habit',
      imageAsset: 'lib/assets/tutorials/habits/swipe_complete.png',
    ),
    TutorialPage(
      instruction: 'View current streak at a glance',
      imageAsset: 'lib/assets/tutorials/habits/view_streak.png',
    ),
    TutorialPage(
      instruction: 'Tap the habit to view details',
      imageAsset: 'lib/assets/tutorials/habits/habit_details.png',
    ),
    TutorialPage(
      instruction: 'Swipe left to delete',
      imageAsset: 'lib/assets/tutorials/habits/delete_habit.png',
    ),
  ];

  static Widget build(BuildContext context, VoidCallback onComplete) {
    return TutorialOverlay(
      pages: pages,
      onComplete: onComplete,
    );
  }
}
