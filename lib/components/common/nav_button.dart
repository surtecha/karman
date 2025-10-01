import 'package:flutter/cupertino.dart';

class NavButton extends StatelessWidget {
  const NavButton({
    super.key,
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.onPressed,
  });

  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(40),
      color: color,
      onPressed: onPressed,
      child: Icon(icon, color: iconColor, size: 18),
    );
  }
}
