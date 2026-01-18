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

  void _warmUpHabitSheet() {
    if (_hasWarmedUpSheet) return;
    _hasWarmedUpSheet = true;

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      
      final overlay = Overlay.of(context);
      late OverlayEntry entry;
      
      entry = OverlayEntry(
        builder: (context) => Offstage(
          child: HabitSheet(habit: null),
        ),
      );
      
      overlay.insert(entry);
      
      Future.delayed(const Duration(milliseconds: 100), () {
        entry.remove();
      });
    });
  }

  void _openHabitSheet({Habit? habit}) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => HabitSheet(habit: habit),
    );
  }

  void _openStreakVisualization() {
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (context) => const StreakVisualizationScreen()),
    );
  }

  void _handleHabitCheckTap(Habit habit, HabitProvider provider) {
    if (provider.isSelectionMode) {
      provider.toggleHabitSelection(habit.id!);
      return;
    }

    if (!habit.isCompletedToday && provider.selectedIndex == 0) {
      HabitCompletionSheet.show(context, habit);
    }
  }

  void _handleDelete(HabitProvider provider) async {
    if (provider.selectedHabitIds.isEmpty) return;

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Habits'),
        content: Text(
          'Are you sure you want to permanently delete ${provider.selectedHabitIds.length} habit(s)?',
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
              provider.deleteSelectedHabits();
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
        final accentColor = AppColorScheme.accent(theme, context);
        
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            backgroundColor: AppColorScheme.backgroundPrimary(theme),
            leading: ContextMenu(
              items: [
                ContextMenuItem(
                  icon: CupertinoIcons.checkmark_circle,
                  iconColor: accentColor,
                  label: 'Select',
                  onTap: habitProvider.toggleSelectionMode,
                ),
                ContextMenuItem(
                  icon: CupertinoIcons.checkmark_alt_circle_fill,
                  iconColor: accentColor,
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
                color: accentColor,
              ),
            ),
            trailing: habitProvider.isSelectionMode
                ? MultiSelectorNavButton(
                    isSelectionMode: true,
                    hasSelectedItems: habitProvider.selectedHabitIds.isNotEmpty,
                    onPressed: () => _handleDelete(habitProvider),
                  )
                : CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _openStreakVisualization,
                    child: Icon(
                      CupertinoIcons.chart_bar_circle,
                      size: 28,
                      color: accentColor,
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
                          onDelete: () => _handleDelete(habitProvider),
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
                              AppColorScheme.accentColors['pink']!.resolveFrom(context),
                              AppColorScheme.accentColors['pink']!.resolveFrom(context),
                            ],
                            onSelectionChanged: habitProvider.setSelectedIndex,
                            initialSelection: habitProvider.selectedIndex,
                          ),
                        ),
                        Expanded(
                          child: habitProvider.isLoading
                              ? const Center(child: CupertinoActivityIndicator())
                              : CustomScrollView(
                                  slivers: [
                                    HabitList(
                                      habits: habitProvider.currentHabits,
                                      onHabitTap: (habit) {
                                        if (habitProvider.isSelectionMode) {
                                          habitProvider.toggleHabitSelection(habit.id!);
                                        } else {
                                          _openHabitSheet(habit: habit);
                                        }
                                      },
                                      onHabitCheckTap: (habit) => _handleHabitCheckTap(habit, habitProvider),
                                      onReorder: habitProvider.reorderHabits,
                                      isSelectionMode: habitProvider.isSelectionMode,
                                      isSelected: habitProvider.isHabitSelected,
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
                          onPressed: _openHabitSheet,
                          color: AppColorScheme.accentColors['pink']!.resolveFrom(context),
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
