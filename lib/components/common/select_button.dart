import 'package:flutter/cupertino.dart';

class SelectButton extends StatelessWidget {
  const SelectButton({
    super.key,
    required this.text,
    required this.color,
    required this.onPressed,
  });

  final String text;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Text(text, style: TextStyle(color: color)),
    );
  }
}