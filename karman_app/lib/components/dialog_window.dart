import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TaskDialog extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final String? initialText;

  TaskDialog({
    required this.controller,
    required this.onSave,
    required this.onCancel,
    this.initialText,
  });

  @override
  Widget build(BuildContext context) {
    if (initialText != null) {
      controller.text = initialText!;
    }

    return CupertinoAlertDialog(
      title: Text(initialText == null ? 'Add Task' : 'Edit Task'),
      content: CupertinoTextField(
        controller: controller,
        placeholder: 'Enter task name',
        autofocus: true,
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: onCancel,
          child: Text('Cancel'),
        ),
        CupertinoDialogAction(
          onPressed: onSave,
          child: Text('Save'),
        ),
      ],
    );
  }
}
