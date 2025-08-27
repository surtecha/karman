import 'package:flutter/cupertino.dart';

class CustomFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CustomFloatingActionButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: CupertinoColors.systemBlue,
          shape: BoxShape.circle,
        ),
        child: Icon(
          CupertinoIcons.add,
          color: CupertinoColors.white,
          size: 24,
        ),
      ),
    );
  }
}