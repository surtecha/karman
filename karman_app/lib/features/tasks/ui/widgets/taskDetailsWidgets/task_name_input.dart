import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TaskNameInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback? onSave;
  final bool isTaskNameEmpty;
  final bool hasChanges;

  const TaskNameInput({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSave,
    required this.isTaskNameEmpty,
    required this.hasChanges,
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
              color: Colors.white,
              fontSize: 20,
            ),
            placeholder: 'Task Name',
            placeholderStyle: TextStyle(
              color: CupertinoColors.systemGrey,
              fontSize: 20,
            ),
            inputFormatters: [
              UpperCaseFirstLetterFormatter(),
            ],
          ),
        ),
        SizedBox(width: 20),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onSave,
          child: Text(
            'Save',
            style: TextStyle(
              color: (hasChanges && !isTaskNameEmpty)
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

class UpperCaseFirstLetterFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isNotEmpty) {
      return TextEditingValue(
        text: newValue.text[0].toUpperCase() + newValue.text.substring(1),
        selection: newValue.selection,
      );
    }
    return newValue;
  }
}
