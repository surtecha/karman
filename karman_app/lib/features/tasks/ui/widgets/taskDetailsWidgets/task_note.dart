import 'package:flutter/cupertino.dart';

class TaskNote extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const TaskNote({
    super.key,
    required this.controller,
    this.hintText = 'Add a note...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.tertiarySystemBackground.darkColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: CupertinoTextField(
        controller: controller,
        style: TextStyle(color: CupertinoColors.white),
        placeholder: hintText,
        placeholderStyle: TextStyle(color: CupertinoColors.systemGrey),
        maxLines: null,
        keyboardType: TextInputType.multiline,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.all(12),
      ),
    );
  }
}
