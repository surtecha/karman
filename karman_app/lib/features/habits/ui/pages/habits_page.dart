import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:karman_app/core/components/badges/achievement_overlay.dart';
import 'package:karman_app/core/components/fab/minimal_floating_action_button.dart';
import 'package:karman_app/features/habits/data/habit.dart';
import 'package:karman_app/features/habits/logic/habit_controller.dart';
import 'package:karman_app/features/habits/ui/pages/habit_details_sheet.dart';
import 'package:karman_app/features/habits/ui/widgets/habit_tile.dart';
import 'package:karman_app/features/welcome_tutorial/ui/pages/tutorial/habit_tutorial.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HabitsPage extends StatefulWidget {
  const HabitsPage({super.key});

  @override
  HabitsPageState createState() => HabitsPageState();
}

class HabitsPageState extends State<HabitsPage> with TickerProviderStateMixin {
  bool _isLoading = true;
  Timer? _debounce;
  bool _showTutorial = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  StreamSubscription? _achievementSubscription;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _loadHabits();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstLaunch();
      _scheduleStreakReminders();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _animationController.dispose();
    _achievementSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadHabits() async {
    final habitController =
        Provider.of<HabitController>(context, listen: false);
    await habitController.loadHabits();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _checkFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('first_launch_habits') ?? true;
    if (isFirstLaunch) {
      await Future.delayed(Duration(milliseconds: 200));
      setState(() {
        _showTutorial = true;
      });
      _animationController.forward();
    }
  }

  void _onTutorialComplete() async {
    await _animationController.reverse();
    setState(() {
      _showTutorial = false;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_launch_habits', false);
  }

  Future<void> _refreshHabits() async {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final habitController =
          Provider.of<HabitController>(context, listen: false);
      await habitController.loadHabits();
      await _scheduleStreakReminders();
    });
  }

  Future<void> _scheduleStreakReminders() async {
    final habitController =
        Provider.of<HabitController>(context, listen: false);
    await habitController.scheduleStreakReminders();
  }

  void _showAddHabitDialog() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => HabitDetailsSheet(
        habit: Habit(
          habitName: '',
          startDate: DateTime.now(),
        ),
        isNewHabit: true,
        autoFocus: true,
      ),
    );
  }

  List<Habit> _sortHabits(List<Habit> habits) {
    habits.sort((a, b) {
      if (a.isCompletedToday == b.isCompletedToday) {
        return 0;
      }
      return a.isCompletedToday ? 1 : -1;
    });
    return habits;
  }

  void _listenForAchievements(HabitController controller) {
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
  Widget build(BuildContext context) {
    return Consumer<HabitController>(
      builder: (context, habitController, child) {
        _listenForAchievements(habitController);
        final sortedHabits = _sortHabits(habitController.habits);
        final incompleteHabits =
            sortedHabits.where((habit) => !habit.isCompletedToday).length;

        return Stack(
          children: [
            CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(
                backgroundColor: CupertinoColors.black,
                middle: Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: Text(
                    sortedHabits.isEmpty
                        ? 'No habits left'
                        : '$incompleteHabits habit${incompleteHabits == 1 ? '' : 's'} left',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              child: SafeArea(
                child: _isLoading
                    ? Center(child: CupertinoActivityIndicator())
                    : sortedHabits.isEmpty
                        ? _buildEmptyState()
                        : CustomScrollView(
                            slivers: [
                              CupertinoSliverRefreshControl(
                                onRefresh: _refreshHabits,
                              ),
                              SliverPadding(
                                padding: EdgeInsets.only(top: 20.0),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      if (index < sortedHabits.length) {
                                        final habit = sortedHabits[index];
                                        return AnimatedSwitcher(
                                          duration: Duration(milliseconds: 300),
                                          child: HabitTile(
                                            key: ValueKey(habit.habitId),
                                            habit: habit,
                                          ),
                                        );
                                      }
                                      return SizedBox(height: 40);
                                    },
                                    childCount: sortedHabits.length + 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
              ),
            ),
            MinimalFloatingActionButton(
              onPressed: _showAddHabitDialog,
              icon: CupertinoIcons.plus,
            ),
            if (_showTutorial)
              FadeTransition(
                opacity: _fadeAnimation,
                child: HabitsTutorial.build(context, _onTutorialComplete),
              ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'No habits yet. Add one to get started!',
        style: TextStyle(
          fontSize: 18,
          color: CupertinoColors.systemGrey,
        ),
      ),
    );
  }
}
