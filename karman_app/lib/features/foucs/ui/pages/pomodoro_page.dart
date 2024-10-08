import 'package:flutter/cupertino.dart';
import 'package:karman_app/app_state.dart';
import 'package:karman_app/features/foucs/logic/pomodoro_controller.dart';
import 'package:karman_app/features/foucs/ui/widgets/pomodoro/pomodoro_session_indicator.dart';
import 'package:karman_app/features/foucs/ui/widgets/pomodoro/pomodoro_session_type_indicator.dart';
import 'package:karman_app/features/foucs/ui/widgets/pomodoro/pomodoro_settings_picker.dart';
import 'package:karman_app/features/foucs/ui/widgets/pomodoro/pomodoro_timer_display.dart';
import 'package:karman_app/features/foucs/ui/widgets/rolling_menu.dart';
import 'package:karman_app/features/welcome_tutorial/ui/pages/tutorial/pomodoro_tutorial.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PomodoroPage extends StatefulWidget {
  const PomodoroPage({super.key});

  @override
  PomodoroPageState createState() => PomodoroPageState();
}

class PomodoroPageState extends State<PomodoroPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isMenuOpen = false;

  bool _showTutorial = false;
  late AnimationController _tutorialAnimationController;
  late Animation<double> _tutorialFadeAnimation;

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
  }

  Future<void> _checkFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('first_launch_pomodoro') ?? true;
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
    await prefs.setBool('first_launch_pomodoro', false);
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

  @override
  void dispose() {
    _animationController.dispose();
    _tutorialAnimationController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop(
      BuildContext context, PomodoroController controller) async {
    if (!controller.isRunning) {
      return true;
    }

    bool? exitConfirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text('Exit Pomodoro Session?'),
        content:
            Text('Are you sure you want to exit the active Pomodoro session?'),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              controller.stopTimer(countSession: false);
              Navigator.of(context).pop(true);
            },
            child: Text('Exit'),
          ),
        ],
      ),
    );

    return exitConfirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PomodoroController(context),
      child: Consumer2<PomodoroController, AppState>(
        builder: (context, controller, appState, child) {
          return WillPopScope(
            onWillPop: () => _onWillPop(context, controller),
            child: CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(
                backgroundColor: CupertinoColors.black,
                border: null,
                middle: Text('Pomodoro Timer',
                    style: TextStyle(color: CupertinoColors.white)),
                leading: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: controller.isRunning
                      ? null
                      : () async {
                          if (await _onWillPop(context, controller)) {
                            Navigator.of(context).pop();
                          }
                        },
                  child: Icon(
                    CupertinoIcons.back,
                    color: controller.isRunning
                        ? CupertinoColors.systemGrey
                        : CupertinoColors.white,
                  ),
                ),
                trailing: controller.isRunning && controller.isFocusSession
                    ? CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: _toggleMenu,
                        child: Icon(
                          controller.soundManager.currentIcon,
                          color: CupertinoColors.white,
                        ),
                      )
                    : null,
              ),
              child: SafeArea(
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              PomodoroTimerDisplay(controller: controller),
                              if (controller.isRunning &&
                                  controller.isFocusSession)
                                Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Text(
                                    controller.currentQuote,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: CupertinoColors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              SizedBox(height: 20),
                              PomodoroSessionIndicator(controller: controller),
                              SizedBox(height: 20),
                              PomodoroSessionTypeIndicator(
                                  isFocusSession: controller.isFocusSession,
                                  isRunning: controller.isRunning),
                              SizedBox(height: 20),
                              CupertinoButton(
                                child: Icon(
                                  controller.isRunning
                                      ? CupertinoIcons.stop_circle
                                      : CupertinoIcons.play_circle,
                                  color: CupertinoColors.white,
                                  size: 56,
                                ),
                                onPressed: () {
                                  controller.toggleTimer();
                                  appState
                                      .setPomodoroActive(controller.isRunning);
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          height: controller.isRunning ? 0 : 300,
                          child: SingleChildScrollView(
                            child:
                                PomodoroSettingsPicker(controller: controller),
                          ),
                        ),
                      ],
                    ),
                    if (controller.isRunning && controller.isFocusSession)
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
                              child: Container(
                                color: CupertinoColors.black.withOpacity(0.8),
                                child: RollingMenu(
                                  items: controller.soundManager.sounds,
                                  onItemSelected: (Map<String, dynamic> sound) {
                                    controller.soundManager.currentSound =
                                        sound['file'];
                                    if (sound['file'] == null) {
                                      controller.soundManager
                                          .stopBackgroundSound();
                                    } else {
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
                        child: PomodoroTutorial.build(
                            context, _onTutorialComplete),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
