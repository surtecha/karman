import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:karman_app/components/dialog_window.dart';
import 'package:karman_app/database/habit_database.dart';
import 'package:karman_app/models/habit.dart';
import 'package:karman_app/utils/habit_utils.dart';
import 'package:provider/provider.dart';

class HabitsPage extends StatefulWidget {
  const HabitsPage({super.key});

  @override
  State<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage> {
  @override
  void initState() {
    // read existing habits on app startup
    Provider.of<HabitDatabase>(context, listen: false).readHabits();
    super.initState();
  }

  // text controller
  final TextEditingController textController = TextEditingController();

  // Create a new habit
  void createNewHabit() {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return KarmanDialogWindow(
            controller: textController,
            onSave: () {
              // get new habit name
              String newHabitName = textController.text;

              // save to db
              context.read<HabitDatabase>().addHabit(newHabitName);

              // close dialog
              Navigator.of(context).pop();

              // clear text field
              textController.clear();
            },
            onCancel: () {
              Navigator.of(context).pop();
              textController.clear();
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.black,
        middle: Text('Habit Tracking'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {},
          child: Icon(
            CupertinoIcons.square_stack,
            color: CupertinoColors.white,
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: createNewHabit,
          child: Icon(
            CupertinoIcons.plus,
            color: CupertinoColors.white,
          ),
        ),
      ),
      child: _buildHabitsList(),
    );
  }

  // build habit list
  Widget _buildHabitsList() {
    // habit db
    final HabitDatabase habitDatabase = context.watch<HabitDatabase>();

    // current habits
    List<Habit> currentHabits = habitDatabase.currentHabits;

    // return list of habits
    return ListView.builder(
      itemCount: currentHabits.length,
      itemBuilder: (context, index) {
        //get individual habit
        final habit = currentHabits[index];

        // check if habit is completed
        bool isCompletedToday = isHabitCompletedToday(habit.completedDays);

        return Material(
          child: ListTile(
            title: Text(habit.name),
          ),
        );
      },
    );
  }
}
