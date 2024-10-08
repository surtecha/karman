import 'package:flutter/cupertino.dart';
import 'tutorial_overlay.dart';

class FocusTutorial {
  static List<TutorialPage> pages = [
    TutorialPage(
      instruction: 'Drag to set time',
      imageAsset: 'lib/assets/tutorials/focus/set_time.png',
    ),
    TutorialPage(
      instruction: 'Tap play to start timer',
      imageAsset: 'lib/assets/tutorials/focus/start_timer.png',
    ),
    TutorialPage(
      instruction: 'Listen to relaxing sounds',
      imageAsset: 'lib/assets/tutorials/focus/relaxing_sounds.png',
    ),
  ];

  static Widget build(BuildContext context, VoidCallback onComplete) {
    return TutorialOverlay(
      pages: pages,
      onComplete: onComplete,
    );
  }
}
