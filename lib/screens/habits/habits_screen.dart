import 'package:flutter/cupertino.dart';
import 'package:karman/components/common/floating_action_button.dart';
import 'package:karman/components/common/multi_selector.dart';
import 'package:karman/components/common/pill_button.dart';
import 'package:karman/components/common/context_menu.dart';
import 'package:karman/components/habits/habit_sheet.dart';
import 'package:karman/components/habits/habit_list.dart';
import 'package:karman/components/habits/habit_completion_sheet.dart';
import 'package:karman/screens/habits/streak_visualization_screen.dart';
import 'package:karman/theme/color_scheme.dart';
import 'package:karman/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import '../../providers/habit_provider.dart';
import '../../models/habit.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  bool _hasWarmedUpSheet = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitProvider>().loadHabits();
      _warmUpHabitSheet();
    });
  }

  // Warm up the HabitSheet to eliminate first-open lag
  void _warmUpHabitSheet() {
    if (_hasWarmedUpSheet) return;
    _hasWarmedUpSheet = true;

    // Build the sheet off-screen using Offstage to cache its render tree
    // This happens after the initial frame, so it doesn't slow down app startup
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      
      // Create an overlay entry that builds the sheet invisibly
      final overlay = Overlay.of(context);
      late OverlayEntry entry;
      
      entry = OverlayEntry(
        builder: (context) => Offstage(
          child: HabitSheet(
            habit: null,
          ),
        ),
      );
      
      overlay.insert(entry);
      
      // Remove it after a brief moment (enough time to build and cache)
      Future.delayed(const Duration(milliseconds: 100), () {
        entry.remove();
      });
    });
  }

  void _openHabitSheet(BuildContext context, {Habit? habit}) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => HabitSheet(habit: habit),
    );
  }

  void _openStreakVisualization(BuildContext context) {
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (context) => const StreakVisualizationScreen()),
    );
  }

  void _handleHabitCheckTap(BuildContext context, Habit habit, HabitProvider habitProvider) {
    if (habitProvider.isSelectionMode) {
      habitProvider.toggleHabitSelection(habit.id!);
      return;
    }

    if (habit.isCompletedToday) {
      return;
    }

    if (habitProvider.selectedIndex == 0) {
      HabitCompletionSheet.show(context, habit);
    }
  }

  void _handleDelete(BuildContext context, HabitProvider habitProvider) async {
    if (habitProvider.selectedHabitIds.isEmpty) return;

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Habits'),
        content: Text(
          'Are you sure you want to permanently delete ${habitProvider.selectedHabitIds.length} habit(s)?',
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.of(context).pop();
              habitProvider.deleteSelectedHabits();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, HabitProvider>(
      builder: (context, theme, habitProvider, child) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            backgroundColor: AppColorScheme.backgroundPrimary(theme),
            leading: ContextMenu(
              items: [
                ContextMenuItem(
                  icon: CupertinoIcons.checkmark_circle,
                  iconColor: AppColorScheme.accent(theme, context),
                  label: 'Select',
                  onTap: () => habitProvider.toggleSelectionMode(),
                ),
                ContextMenuItem(
                  icon: CupertinoIcons.checkmark_alt_circle_fill,
                  iconColor: AppColorScheme.accent(theme, context),
                  label: 'Select All',
                  onTap: () {
                    habitProvider.toggleSelectionMode();
                    for (var habit in habitProvider.currentHabits) {
                      if (!habitProvider.isHabitSelected(habit.id!)) {
                        habitProvider.toggleHabitSelection(habit.id!);
                      }
                    }
                  },
                ),
              ],
              child: Icon(
                CupertinoIcons.ellipsis_circle,
                size: 28,
                color: AppColorScheme.accent(theme, context),
              ),
            ),
            trailing: habitProvider.isSelectionMode
                ? MultiSelectorNavButton(
                    isSelectionMode: habitProvider.isSelectionMode,
                    hasSelectedItems: habitProvider.selectedHabitIds.isNotEmpty,
                    onPressed: () {
                      _handleDelete(context, habitProvider);
                    },
                  )
                : CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => _openStreakVisualization(context),
                    child: Icon(
                      CupertinoIcons.chart_bar_circle,
                      size: 28,
                      color: AppColorScheme.accent(theme, context),
                    ),
                  ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    Column(
                      children: [
                        MultiSelector<int>(
                          isActive: habitProvider.isSelectionMode,
                          selectedItems: habitProvider.selectedHabitIds,
                          onToggleMode: habitProvider.toggleSelectionMode,
                          onDelete: () {
                            _handleDelete(context, habitProvider);
                          },
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: PillButton(
                            options: const ['Today', 'Scheduled'],
                            counts: [
                              habitProvider.todayHabits.length,
                              habitProvider.scheduledHabits.length,
                            ],
                            colors: [
                              AppColorScheme.accent(theme, context),
                              AppColorScheme.accentColors['purple']!.resolveFrom(context),
                            ],
                            onSelectionChanged: habitProvider.setSelectedIndex,
                            initialSelection: habitProvider.selectedIndex,
                          ),
                        ),
                        Expanded(
                          child:
                              habitProvider.isLoading
                                  ? const Center(
                                    child: CupertinoActivityIndicator(),
                                  )
                                  : CustomScrollView(
                                    slivers: [
                                      HabitList(
                                        habits: habitProvider.currentHabits,
                                        onHabitTap:
                                            (habit) {
                                              if (habitProvider.isSelectionMode) {
                                                habitProvider.toggleHabitSelection(habit.id!);
                                              } else {
                                                _openHabitSheet(context, habit: habit);
                                              }
                                            },
                                        onHabitCheckTap:
                                            (habit) => _handleHabitCheckTap(
                                              context,
                                              habit,
                                              habitProvider,
                                            ),
                                        onReorder:
                                            (oldIndex, newIndex) =>
                                                habitProvider.reorderHabits(
                                                  oldIndex,
                                                  newIndex,
                                                ),
                                        isSelectionMode: habitProvider.isSelectionMode,
                                        isSelected: (id) => habitProvider.isHabitSelected(id),
                                      ),
                                    ],
                                  ),
                        ),
                      ],
                    ),
                    if (!habitProvider.isSelectionMode)
                      Positioned(
                        bottom: constraints.maxHeight > 600 ? 20 : 16,
                        right: constraints.maxWidth < 350 ? 16 : 20,
                        child: CustomFloatingActionButton(
                          onPressed: () => _openHabitSheet(context),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}