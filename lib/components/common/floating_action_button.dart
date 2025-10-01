import 'package:flutter/cupertino.dart';
import 'package:karman/theme/color_scheme.dart';
import 'package:karman/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class CustomFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CustomFloatingActionButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, child) {
        return GestureDetector(
          onTap: onPressed,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColorScheme.accent(theme, context),
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.add,
              color:
                  theme.isDark ? CupertinoColors.black : CupertinoColors.white,
              size: 24,
            ),
          ),
        );
      },
    );
  }
}
