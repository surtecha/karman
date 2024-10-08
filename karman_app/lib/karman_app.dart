import 'package:flutter/cupertino.dart';
import 'package:karman_app/app_shell.dart';
import 'package:karman_app/features/welcome_tutorial/ui/pages/welcome/welcome_screen.dart';

class KarmanApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final bool showWelcome;
  final int initialTabIndex;

  const KarmanApp({
    super.key,
    required this.navigatorKey,
    required this.showWelcome,
    required this.initialTabIndex,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(
        brightness: Brightness.dark,
      ),
      home: showWelcome
          ? const WelcomeScreen()
          : AppShell(key: AppShell.globalKey, initialTabIndex: initialTabIndex),
    );
  }
}
