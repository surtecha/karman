import 'package:flutter/cupertino.dart';
import 'package:karman/theme/theme_provider.dart';
import 'package:karman/theme/color_scheme.dart';
import 'package:provider/provider.dart';

class AppearanceSelector extends StatelessWidget {
  const AppearanceSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 12),
              child: Text(
                'APPEARANCE',
                style: TextStyle(
                  color: AppColorScheme.textSecondary(theme),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColorScheme.backgroundSecondary(theme),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildThemeOption(
                    theme,
                    context,
                    AppThemeMode.light,
                    'Light',
                    CupertinoIcons.sun_max_fill,
                    isFirst: true,
                  ),
                  _buildDivider(theme),
                  _buildThemeOption(
                    theme,
                    context,
                    AppThemeMode.dark,
                    'Dark',
                    CupertinoIcons.moon_fill,
                  ),
                  _buildDivider(theme),
                  _buildThemeOption(
                    theme,
                    context,
                    AppThemeMode.system,
                    'System',
                    CupertinoIcons.gear_alt_fill,
                    isLast: true,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildThemeOption(
      ThemeProvider theme,
      BuildContext context,
      AppThemeMode mode,
      String title,
      IconData icon, {
        bool isFirst = false,
        bool isLast = false,
      }) {
    final isSelected = theme.themeMode == mode;

    return GestureDetector(
      onTap: () => theme.setThemeMode(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(
            top: isFirst ? const Radius.circular(12) : Radius.zero,
            bottom: isLast ? const Radius.circular(12) : Radius.zero,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColorScheme.accent(theme, context).withOpacity(0.15)
                    : AppColorScheme.backgroundTertiary(theme),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 18,
                color: isSelected
                    ? AppColorScheme.accent(theme, context)
                    : AppColorScheme.textSecondary(theme),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: AppColorScheme.textPrimary(theme),
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                CupertinoIcons.checkmark,
                size: 18,
                color: AppColorScheme.accent(theme, context),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(ThemeProvider theme) {
    return Container(
      margin: const EdgeInsets.only(left: 68),
      height: 0.5,
      color: AppColorScheme.borderSubtle(theme),
    );
  }
}