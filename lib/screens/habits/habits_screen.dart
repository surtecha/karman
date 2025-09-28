import 'package:flutter/cupertino.dart';
import 'package:karman/theme/color_scheme.dart';
import 'package:karman/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, child) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text('Habits'),
          ),
          child: SafeArea(
            child: Center(
              child: Text(
                'Habits Screen',
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