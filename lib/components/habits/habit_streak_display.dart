import 'package:flutter/cupertino.dart';
import 'package:karman/theme/color_scheme.dart';
import 'package:karman/theme/theme_provider.dart';

class HabitStreakDisplay extends StatelessWidget {
  final int currentStreak;
  final int maxStreak;
  final ThemeProvider theme;

  const HabitStreakDisplay({
    super.key,
    required this.currentStreak,
    required this.maxStreak,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColorScheme.backgroundPrimary(theme),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColorScheme.textSecondary(theme).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStreakColumn(
            icon: CupertinoIcons.flame_fill,
            value: currentStreak,
            label: 'Current',
          ),
          Container(
            height: 50,
            width: 1,
            color: AppColorScheme.textSecondary(theme).withOpacity(0.2),
          ),
          _buildStreakColumn(
            icon: CupertinoIcons.rosette,
            value: maxStreak,
            label: 'Best',
          ),
        ],
      ),
    );
  }

  Widget _buildStreakColumn({
    required IconData icon,
    required int value,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 24,
          color: AppColorScheme.textPrimary(theme),
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return ScaleTransition(
              scale: animation,
              child: child,
            );
          },
          child: Text(
            '$value',
            key: ValueKey(value),
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppColorScheme.textPrimary(theme),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: AppColorScheme.textSecondary(theme),
          ),
        ),
      ],
    );
  }
}