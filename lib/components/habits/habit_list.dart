import 'package:flutter/cupertino.dart';
import 'package:karman/components/habits/habit_tile.dart';
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
            style: TextStyle(
              fontSize: 16,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ),
      );
    }

    return SliverReorderableList(
      itemBuilder: (context, index) {
        final habit = habits[index];
        return ReorderableDelayedDragStartListener(
          key: Key('${habit.id}'),
          index: index,
          enabled: !isSelectionMode,
          child: HabitTile(
            habit: habit,
            onTap: () => onHabitTap(habit),
            onCheckTap: () => onHabitCheckTap(habit),
            isSelected: isSelected(habit.id!),
            isSelectionMode: isSelectionMode,
          ),
        );
      },
      itemCount: habits.length,
      onReorder: onReorder,
    );
  }
}
