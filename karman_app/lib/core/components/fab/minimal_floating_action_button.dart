import 'package:flutter/cupertino.dart';

class MinimalFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final dynamic icon;
  final double size;

  const MinimalFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 24, bottom: 24),
          child: GestureDetector(
            onTap: onPressed,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: CupertinoColors.black,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.white.withOpacity(0.15),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: _buildIcon(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (icon is IconData) {
      return Icon(
        icon as IconData,
        color: CupertinoColors.white,
        size: size * 0.5,
      );
    } else if (icon is String) {
      return Image.asset(
        icon as String,
      );
    } else {
      throw ArgumentError(
          'Invalid icon type. Must be IconData or String (SVG asset path).');
    }
  }
}
