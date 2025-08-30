import 'package:flutter/cupertino.dart';
import 'package:karman/color_scheme.dart';

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
          color: AppColorScheme.accent(context),
          shape: BoxShape.circle,
        ),
        child: Icon(
          CupertinoIcons.add,
          color: MediaQuery.of(context).platformBrightness == Brightness.dark
              ? CupertinoColors.black
              : CupertinoColors.white,
          size: 24,
        ),
      ),
    );
  }
}