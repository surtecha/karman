import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TaskNameInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSave;

  const TaskNameInput({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: CupertinoTextField(
              controller: controller,
              focusNode: focusNode,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
              placeholder: 'Task Name',
              placeholderStyle: TextStyle(
                color: Colors.grey,
                fontSize: 24,
              ),
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onSave,
            child: Icon(
              CupertinoIcons.check_mark_circled,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}