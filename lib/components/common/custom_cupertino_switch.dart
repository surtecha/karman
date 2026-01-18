import 'package:flutter/material.dart';
import 'package:karman/theme/color_scheme.dart';
import 'package:karman/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class CustomCupertinoSwitch extends StatelessWidget {
  final bool value;
  final Function(bool) onChanged;

  const CustomCupertinoSwitch({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, child) {
        return Material(
          color: Colors.transparent,
          child: Switch(
            value: value,
            activeThumbColor: AppColorScheme.backgroundPrimary(theme),
            activeTrackColor: AppColorScheme.accent(theme, context),
            inactiveTrackColor: AppColorScheme.backgroundSecondary(theme),
            trackOutlineColor: WidgetStateProperty.all(
              AppColorScheme.backgroundSecondary(theme),
            ),
            onChanged: onChanged,
          ),
        );
      },
    );
  }
}
