import 'package:flutter/cupertino.dart';
import 'package:karman/theme/color_scheme.dart';
import 'package:karman/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class StreakVisualizationScreen extends StatelessWidget {
  const StreakVisualizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, child) {
        return CupertinoPageScaffold(
          backgroundColor: AppColorScheme.backgroundPrimary(theme),
          navigationBar: CupertinoNavigationBar(
            backgroundColor: AppColorScheme.backgroundPrimary(theme),
            middle: const Text('Streak Visualization'),
          ),
          child: SafeArea(
            child: Center(
              child: Text(
                'Coming Soon',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColorScheme.textSecondary(theme),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
