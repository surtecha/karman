import 'package:flutter/cupertino.dart';
import 'package:karman/components/settings/appearance_selector.dart';
import 'package:karman/theme/theme_provider.dart';
import 'package:karman/theme/color_scheme.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, child) {
        return CupertinoPageScaffold(
          backgroundColor: AppColorScheme.backgroundPrimary(theme),
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 20),
                const AppearanceSelector(),
              ],
            ),
          ),
        );
      },
    );
  }
}
