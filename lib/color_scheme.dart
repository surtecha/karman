import 'package:flutter/cupertino.dart';

class AppColorScheme extends InheritedWidget {
  const AppColorScheme({
    super.key,
    required super.child,
  });

  static AppColorScheme of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<AppColorScheme>();
    assert(result != null, 'No AppColorScheme found in context');
    return result!;
  }

  static bool _isDarkMode(BuildContext context) =>
      MediaQuery.of(context).platformBrightness == Brightness.dark;

  static Color defaultColor(BuildContext context) {
    return _isDarkMode(context)
        ? CupertinoColors.white
        : CupertinoColors.black;
  }
  static const Color red = CupertinoColors.systemRed;
  static const Color blue = CupertinoColors.systemBlue;
  static const Color green = CupertinoColors.systemGreen;
  static const Color orange = CupertinoColors.systemOrange;
  static const Color purple = CupertinoColors.systemPurple;
  static const Color indigo = CupertinoColors.systemIndigo;
  static const Color cyan = CupertinoColors.systemCyan;

  static Color primary(BuildContext context) {
    return CupertinoColors.systemBackground;
  }

  static Color secondary(BuildContext context) {
    return _isDarkMode(context)
        ? CupertinoColors.darkBackgroundGray
        : CupertinoColors.extraLightBackgroundGray;
  }

  static Color accent(BuildContext context) {
    return AppColorScheme.defaultColor(context);
  }

  static Color textPrimary(BuildContext context) {
    return _isDarkMode(context)
        ? CupertinoColors.white
        : CupertinoColors.black;
  }

  static Color textSecondary(BuildContext context) {
    return _isDarkMode(context)
        ? CupertinoColors.systemGrey
        : CupertinoColors.systemGrey2;
  }

  @override
  bool updateShouldNotify(AppColorScheme oldWidget) {
    return false;
  }
}