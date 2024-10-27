import 'package:flutter/cupertino.dart';

class HabitNameField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isHabitNameEmpty;
  final bool hasChanges;
  final VoidCallback onSave;

  const HabitNameField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isHabitNameEmpty,
    required this.hasChanges,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CupertinoTextField(
            controller: controller,
            focusNode: focusNode,
            style: TextStyle(
              color: isHabitNameEmpty
                  ? CupertinoColors.systemGrey
                  : CupertinoColors.white,
              fontSize: 20,
            ),
            placeholder: 'Habit Name',
            placeholderStyle: TextStyle(
              color: CupertinoColors.systemGrey,
              fontSize: 20,
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
        ),
        SizedBox(width: 20),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: hasChanges && !isHabitNameEmpty ? onSave : null,
          child: Text(
            'Save',
            style: TextStyle(
              color: hasChanges && !isHabitNameEmpty
                  ? CupertinoColors.white
                  : CupertinoColors.systemGrey,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
