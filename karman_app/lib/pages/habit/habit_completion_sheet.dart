import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:karman_app/models/habits/habit.dart';
import 'package:karman_app/controllers/habit/habit_controller.dart';
import 'package:provider/provider.dart';
import 'package:slide_to_act/slide_to_act.dart';

class HabitCompletionSheet extends StatefulWidget {
  final Habit habit;

  const HabitCompletionSheet({
    super.key,
    required this.habit,
  });

  @override
  _HabitCompletionSheetState createState() => _HabitCompletionSheetState();
}

class _HabitCompletionSheetState extends State<HabitCompletionSheet> {
  final TextEditingController _logController = TextEditingController();

  @override
  void dispose() {
    _logController.dispose();
    super.dispose();
  }

  Future<void> _completeHabit() async {
    final habitController = context.read<HabitController>();
    await habitController.completeHabitForToday(
        widget.habit, _logController.text);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          decoration: BoxDecoration(
            color: CupertinoColors.darkBackgroundGray,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Complete ${widget.habit.habitName}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              _buildLogField(),
              SizedBox(height: 20),
              _buildSlideToAct(),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Log (Optional):',
          style: TextStyle(color: CupertinoColors.white, fontSize: 16),
        ),
        SizedBox(height: 8),
        TaskNote(
          controller: _logController,
          hintText: 'Enter your log here...',
        ),
      ],
    );
  }

  Widget _buildSlideToAct() {
    return SlideAction(
      innerColor: CupertinoColors.darkBackgroundGray,
      outerColor: CupertinoColors.tertiarySystemBackground.darkColor,
      sliderButtonIcon: Icon(
        CupertinoIcons.leaf_arrow_circlepath,
        color: CupertinoColors.white,
      ),
      sliderRotate: false,
      elevation: 0,
      text: 'Complete your habit →',
      textStyle: TextStyle(
        color: CupertinoColors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      submittedIcon: Icon(
        CupertinoIcons.check_mark,
        color: CupertinoColors.white,
        size: 40,
      ),
      animationDuration: Duration(milliseconds: 350),
      onSubmit: _completeHabit,
    );
  }
}

class TaskNote extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;

  const TaskNote({
    super.key,
    required this.controller,
    this.hintText = 'Add a note...',
  });

  @override
  _TaskNoteState createState() => _TaskNoteState();
}

class _TaskNoteState extends State<TaskNote> {
  int _noteLines = 1;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateNoteLines);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateNoteLines);
    super.dispose();
  }

  void _updateNoteLines() {
    final newLines = '\n'.allMatches(widget.controller.text).length + 1;
    if (newLines != _noteLines) {
      setState(() {
        _noteLines = newLines;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.tertiarySystemBackground.darkColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: CupertinoTextField(
        controller: widget.controller,
        style: TextStyle(color: Colors.white),
        maxLines: null,
        keyboardType: TextInputType.multiline,
        placeholder: widget.hintText,
        placeholderStyle: TextStyle(color: Colors.grey),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.transparent),
        ),
        padding: EdgeInsets.all(12),
      ),
    );
  }
}
