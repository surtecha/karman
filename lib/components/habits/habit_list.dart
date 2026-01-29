import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:karman/components/habits/habit_tile.dart';
import 'package:karman/theme/color_scheme.dart';
import 'package:karman/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import '../../models/habit.dart';

class HabitList extends StatelessWidget {
  final List<Habit> habits;
  final Function(Habit) onHabitTap;
  final Function(Habit) onHabitCheckTap;
  final Function(int, int) onReorder;
  final bool isSelectionMode;
  final bool Function(int) isSelected;

  const HabitList({
    super.key,
    required this.habits,
    required this.onHabitTap,
    required this.onHabitCheckTap,
    required this.onReorder,
    required this.isSelectionMode,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (habits.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Text(
            'No habits yet',
            style: TextStyle(fontSize: 16, color: CupertinoColors.systemGrey),
          ),
        ),
      );
    }

    return Consumer<ThemeProvider>(
      builder: (context, theme, child) {
        return SliverToBoxAdapter(
          child: Material(
            color: Colors.transparent,
            child: Localizations(
              locale: const Locale('en', 'US'),
              delegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              child: ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: habits.length,
                itemBuilder: (context, index) {
                  final habit = habits[index];
                  return Container(
                    key: ValueKey(habit.id),
                    child: HabitTile(
                      habit: habit,
                      onTap: () => onHabitTap(habit),
                      onCheckTap: () => onHabitCheckTap(habit),
                      isSelected: isSelected(habit.id!),
                      isSelectionMode: isSelectionMode,
                    ),
                  );
                },
                onReorder: (oldIndex, newIndex) {
                  if (oldIndex < newIndex) newIndex -= 1;
                  HapticFeedback.lightImpact();
                  onReorder(oldIndex, newIndex);
                },
                proxyDecorator: (child, index, animation) {
                  return AnimatedBuilder(
                    animation: animation,
                    builder: (context, child) {
                      final animValue = Curves.fastOutSlowIn.transform(
                        animation.value,
                      );
                      return Transform.scale(
                        scale: 1.0 + (animValue * 0.05),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColorScheme.backgroundPrimary(theme),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: AppColorScheme.shadow(theme),
                                blurRadius: animValue * 8,
                                offset: Offset(0, animValue * 4),
                              ),
                            ],
                          ),
                          child: child,
                        ),
                      );
                    },
                    child: child,
                  );
                },
                buildDefaultDragHandles: !isSelectionMode,
              ),
            ),
          ),
        );
      },
    );
  }
}
