import 'package:flutter/cupertino.dart';
import 'theme_provider.dart';

class AppColorScheme {
  static Color backgroundPrimary(ThemeProvider theme) {
    return theme.isDark ? CupertinoColors.black : CupertinoColors.white;
  }

  static Color backgroundSecondary(ThemeProvider theme) {
    return theme.isDark
        ? CupertinoColors.systemGrey6.darkColor
        : CupertinoColors.systemGrey6.color;
  }

  static Color backgroundTertiary(ThemeProvider theme) {
    return theme.isDark
        ? CupertinoColors.systemGrey5.darkColor
        : CupertinoColors.systemGrey5.color;
  }

  static Color surfaceElevated(ThemeProvider theme) {
    return theme.isDark
        ? CupertinoColors.systemGrey4.darkColor
        : CupertinoColors.systemGrey5;
  }

  static Color textPrimary(ThemeProvider theme) {
    return theme.isDark ? CupertinoColors.white : CupertinoColors.black;
  }

  static Color textSecondary(ThemeProvider theme) {
    return theme.isDark
        ? CupertinoColors.systemGrey.darkColor
        : CupertinoColors.systemGrey.color;
  }

  static Color textTertiary(ThemeProvider theme) {
    return theme.isDark
        ? CupertinoColors.systemGrey2.darkColor
        : CupertinoColors.systemGrey2.color;
  }

  static Color textDisabled(ThemeProvider theme) {
    return theme.isDark
        ? CupertinoColors.systemGrey4.darkColor
        : CupertinoColors.systemGrey4.color;
  }

  static Color accent(ThemeProvider theme, BuildContext context) {
    return theme.accentColor.resolveFrom(context);
  }

  static Color border(ThemeProvider theme) {
    return theme.isDark
        ? CupertinoColors.systemGrey4.darkColor
        : CupertinoColors.systemGrey4.color;
  }

  static Color borderSubtle(ThemeProvider theme) {
    return theme.isDark
        ? CupertinoColors.systemGrey5.darkColor
        : CupertinoColors.systemGrey5.color;
  }

  static Color separator(BuildContext context) {
    return CupertinoColors.separator.resolveFrom(context);
  }

  static Color overlay(ThemeProvider theme) {
    return theme.isDark
        ? CupertinoColors.black.withValues(alpha: 0.6)
        : CupertinoColors.black.withValues(alpha: 0.4);
  }

  static Color shadow(ThemeProvider theme) {
    return theme.isDark
        ? CupertinoColors.black.withValues(alpha: 0.3)
        : CupertinoColors.black.withValues(alpha: 0.1);
  }

  // Red reserved for system indicators (delete, overdue)
  static Color destructive(BuildContext context) {
    return CupertinoColors.destructiveRed.resolveFrom(context);
  }

  static const Map<String, CupertinoDynamicColor> accentColors = {
    'default': CupertinoDynamicColor.withBrightness(
      color: Color(0xFF000000),
      darkColor: Color(0xFFFFFFFF),
    ),
    'purple': CupertinoColors.systemPurple,
    'indigo': CupertinoColors.systemIndigo,
    'blue': CupertinoColors.systemBlue,
    'green': CupertinoColors.systemGreen,
    'yellow': CupertinoColors.systemYellow,
    'orange': CupertinoColors.systemOrange,
    'pink': CupertinoColors.systemPink
  };
}