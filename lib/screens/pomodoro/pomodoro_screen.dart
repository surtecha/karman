import 'package:flutter/cupertino.dart';
import 'package:karman/theme/color_scheme.dart';
import 'package:karman/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class PomodoroScreen extends StatelessWidget {
  const PomodoroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, child) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text('Pomodoro'),
          ),
          child: SafeArea(
            child: Center(
              child: Text(
                'Pomodoro Screen',
                style: TextStyle(
                  fontSize: 24,
                  color: AppColorScheme.textPrimary(theme),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}