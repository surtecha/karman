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

  static Color primary(BuildContext context) {
    return CupertinoColors.systemBackground;
  }

  static Color secondary(BuildContext context) {
    return MediaQuery.of(context).platformBrightness == Brightness.dark
        ? CupertinoColors.darkBackgroundGray
        : CupertinoColors.systemGrey6;
  }

  static Color accent(BuildContext context) {
    return CupertinoColors.systemBlue;
  }

  static Color textPrimary(BuildContext context) {
    return MediaQuery.of(context).platformBrightness == Brightness.dark
        ? CupertinoColors.white
        : CupertinoColors.black;
  }

  static Color textSecondary(BuildContext context) {
    return MediaQuery.of(context).platformBrightness == Brightness.dark
        ? CupertinoColors.systemGrey
        : CupertinoColors.systemGrey2;
  }

  static const Color red = CupertinoColors.systemRed;
  static const Color blue = CupertinoColors.systemBlue;
  static const Color orange = CupertinoColors.systemOrange;
  static const Color green = CupertinoColors.systemGreen;
  static const Color purple = CupertinoColors.systemPurple;
  static const Color teal = CupertinoColors.systemTeal;

  @override
  bool updateShouldNotify(AppColorScheme oldWidget) {
    return false;
  }
}