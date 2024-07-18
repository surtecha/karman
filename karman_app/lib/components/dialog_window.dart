import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class KarmanDialogWindow extends StatelessWidget {
  final String title;
  final String placeholder;
  final TextEditingController controller;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final String? initialText;
  final String cancelText;
  final String saveText;
  final Widget? additionalContent;

  const KarmanDialogWindow({
    Key? key,
    required this.title,
    required this.placeholder,
    required this.controller,
    required this.onSave,
    required this.onCancel,
    this.initialText,
    this.cancelText = 'Cancel',
    this.saveText = 'Save',
    this.additionalContent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (initialText != null) {
      controller.text = initialText!;
    }

    return CupertinoAlertDialog(
      title: Text(title),
      content: Column(
        children: [
          CupertinoTextField(
            controller: controller,
            placeholder: placeholder,
            autofocus: true,
          ),
          if (additionalContent != null) ...[
            const SizedBox(height: 16),
            additionalContent!,
          ],
        ],
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: onCancel,
          child: Text(cancelText),
        ),
        CupertinoDialogAction(
          onPressed: onSave,
          child: Text(saveText),
        ),
      ],
    );
  }
}
