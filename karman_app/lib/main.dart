import 'package:flutter/cupertino.dart';
import 'package:karman_app/app_shell.dart';

void main() {
  runApp(KarmanApp());
}

class KarmanApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        brightness: Brightness.dark,
      ),
      home: AppShell(),
    );
  }
}
