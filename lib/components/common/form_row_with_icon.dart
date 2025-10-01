import 'package:flutter/cupertino.dart';
import 'package:karman/theme/color_scheme.dart';
import 'package:karman/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class FormRowWithIcon extends StatelessWidget {
  const FormRowWithIcon({
    super.key,
    required this.icon,
    required this.label,
    required this.context,
    required this.child,
  });

  final IconData icon;
  final String label;
  final BuildContext context;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, child) {
        return CupertinoFormRow(
          prefix: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColorScheme.accent(theme, context)),
              const SizedBox(width: 12),
              Text(label),
            ],
          ),
          child: this.child,
        );
      },
    );
  }
}
