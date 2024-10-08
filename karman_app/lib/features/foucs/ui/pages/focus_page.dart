import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:karman_app/app_state.dart';
import 'package:karman_app/core/components/badges/achievement_overlay.dart';
import 'package:karman_app/core/components/fab/minimal_floating_action_button.dart';
import 'package:karman_app/features/foucs/logic/focus_controller.dart';
import 'package:karman_app/features/foucs/ui/pages/pomodoro_page.dart';
import 'package:karman_app/features/foucs/ui/widgets/circular_slider.dart';
import 'package:karman_app/features/foucs/ui/widgets/rolling_menu.dart';
import 'package:karman_app/features/welcome_tutorial/ui/pages/tutorial/focus_tutorial.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FocusPage extends StatefulWidget {
  const FocusPage({super.key});

  @override
  FocusPageState createState() => FocusPageState();
}

class FocusPageState extends State<FocusPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isMenuOpen = false;

  bool _showTutorial = false;
  late AnimationController _tutorialAnimationController;
  late Animation<double> _tutorialFadeAnimation;

  late AnimationController _fabAnimationController;
  late Animation<Offset> _fabAnimation;

  StreamSubscription? _achievementSubscription;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstLaunch();
    });
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    _tutorialAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _tutorialFadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(_tutorialAnimationController);
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 2),
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _checkFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('first_launch_focus') ?? true;
    if (isFirstLaunch) {
      await Future.delayed(Duration(milliseconds: 200));
      setState(() {
        _showTutorial = true;
      });
      _tutorialAnimationController.forward();
    }
  }

  void _onTutorialComplete() async {
    await _tutorialAnimationController.reverse();
    setState(() {
      _showTutorial = false;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_launch_focus', false);
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _listenForAchievements(FocusController controller) {
    _achievementSubscription?.cancel();
    _achievementSubscription =
        controller.achievementStream.listen((achievedBadges) {
      for (String badgeName in achievedBadges) {
        _showAchievementOverlay(badgeName);
      }
    });
  }

  void _showAchievementOverlay(String badgeName) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => AchievementOverlay(
        badgeName: badgeName,
        onDismiss: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tutorialAnimationController.dispose();
    _fabAnimationController.dispose();
    _achievementSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FocusController(),
      child: Consumer2<FocusController, AppState>(
        builder: (context, controller, appState, child) {
          return FutureBuilder(
            future: Future.microtask(() => _listenForAchievements(controller)),
            builder: (context, snapshot) {
              if (controller.isTimerRunning &&
                  _fabAnimationController.isDismissed) {
                _fabAnimationController.forward();
              } else if (!controller.isTimerRunning &&
                  _fabAnimationController.isCompleted) {
                _fabAnimationController.reverse();
              }
              return CupertinoPageScaffold(
                navigationBar: CupertinoNavigationBar(
                  backgroundColor: CupertinoColors.black,
                  border: null,
                  padding: EdgeInsetsDirectional.fromSTEB(16, 10, 16, 10),
                  trailing: controller.isTimerRunning
                      ? CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: _toggleMenu,
                          child: Icon(
                            controller.soundManager.currentIcon,
                            color: CupertinoColors.white,
                            size: 28,
                          ),
                        )
                      : null,
                ),
                child: SafeArea(
                  child: Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: CircularSlider(
                            onValueChanged: controller.onSliderValueChanged,
                            currentValue: controller.timerValue,
                            isTimerRunning: controller.isTimerRunning,
                            timeDisplay: controller
                                .formatTime(controller.remainingSeconds),
                            progress: controller.progress,
                            onPlayPause: controller.toggleTimer,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        left: 0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SizedBox(height: 44),
                            SizeTransition(
                              sizeFactor: _animation,
                              axisAlignment: -1,
                              child: Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: RollingMenu(
                                  items: controller.soundManager.sounds,
                                  onItemSelected: (Map<String, dynamic> sound) {
                                    controller.soundManager.currentSound =
                                        sound['file'];
                                    if (sound['file'] == null) {
                                      controller.soundManager
                                          .stopBackgroundSound();
                                    } else if (controller.isTimerRunning) {
                                      controller.soundManager
                                          .playSelectedSound();
                                    }
                                    _toggleMenu();
                                  },
                                  currentSound:
                                      controller.soundManager.currentSound,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_showTutorial)
                        FadeTransition(
                          opacity: _tutorialFadeAnimation,
                          child:
                              FocusTutorial.build(context, _onTutorialComplete),
                        ),
                      SlideTransition(
                        position: _fabAnimation,
                        child: MinimalFloatingActionButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                  builder: (context) => PomodoroPage()),
                            );
                          },
                          icon: 'lib/assets/images/pomodoro/pomo_active.png',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
