import 'package:flutter/cupertino.dart';
import 'tutorial_overlay.dart';

class TasksTutorial {
  static List<TutorialPage> pages = [
    TutorialPage(
      instruction: 'Create new tasks',
      imageAsset: 'lib/assets/tutorials/tasks/create_task.png',
    ),
    TutorialPage(
      instruction: 'Accomplish your tasks',
      imageAsset: 'lib/assets/tutorials/tasks/complete_task.png',
    ),
    TutorialPage(
      instruction: 'Set priority, reminders and due dates',
      imageAsset: 'lib/assets/tutorials/tasks/task_details.png',
    ),
    TutorialPage(
      instruction: 'Clear all completed tasks at once',
      imageAsset: 'lib/assets/tutorials/tasks/clear_completed.png',
    ),
    TutorialPage(
      instruction: 'Swipe a task to the left to delete it',
      imageAsset: 'lib/assets/tutorials/tasks/delete_task.png',
    ),
  ];

  static Widget build(BuildContext context, VoidCallback onComplete) {
    return TutorialOverlay(
      pages: pages,
      onComplete: onComplete,
    );
  }
}
