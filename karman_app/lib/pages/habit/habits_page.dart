import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:karman_app/components/habit/habit_tile.dart';
import 'package:karman_app/controllers/habit/habit_controller.dart';
import 'package:karman_app/models/habits/habit.dart';
import 'package:provider/provider.dart';

class HabitsPage extends StatefulWidget {
  const HabitsPage({super.key});

  @override
  _HabitsPageState createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage> {
  final TextEditingController _newHabitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final habitController =
          Provider.of<HabitController>(context, listen: false);
      habitController.checkAndResetStreaks();
      habitController.loadHabits();
    });
  }

  @override
  void dispose() {
    _newHabitController.dispose();
    super.dispose();
  }

  void _showAddHabitDialog() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text('Add New Habit'),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: CupertinoTextField(
            controller: _newHabitController,
            placeholder: 'Enter habit name',
            autofocus: true,
          ),
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
              _newHabitController.clear();
            },
          ),
          CupertinoDialogAction(
            child: Text('Add'),
            onPressed: () {
              if (_newHabitController.text.isNotEmpty) {
                final newHabit =
                    Habit(habitName: _newHabitController.text.trim());
                Provider.of<HabitController>(context, listen: false)
                    .addHabit(newHabit);
                Navigator.of(context).pop();
                _newHabitController.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitController>(
      builder: (context, habitController, child) {
        final incompleteHabits = habitController.habits
            .where((habit) => !habit.isCompletedToday)
            .length;

        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            backgroundColor: CupertinoColors.black,
            middle: Text('$incompleteHabits habits left'),
            trailing: CupertinoButton(
              onPressed: _showAddHabitDialog,
              child: Icon(
                CupertinoIcons.plus_circle_fill,
                color: CupertinoColors.white,
                size: 32,
              ),
            ),
          ),
          child: SafeArea(
            child: habitController.habits.isEmpty
                ? Center(
                    child: Text(
                      'No habits yet. Add one to get started!',
                      style: TextStyle(color: CupertinoColors.systemGrey),
                    ),
                  )
                : ListView.builder(
                    itemCount: habitController.habits.length,
                    itemBuilder: (context, index) {
                      final habit = habitController.habits[index];
                      return HabitTile(
                        habit: habit,
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}
