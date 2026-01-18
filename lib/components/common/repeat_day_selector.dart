import 'package:flutter/cupertino.dart';
import 'package:karman/theme/color_scheme.dart';
import 'package:karman/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class RepeatDaySelector extends StatelessWidget {
  final Set<int> selectedDays;
  final Function(int) onDayToggle;

  const RepeatDaySelector({
    super.key,
    required this.selectedDays,
    required this.onDayToggle,
  });

  static const List<String> _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, child) {
        final accentColor = AppColorScheme.accent(theme, context);
        final textSecondary = AppColorScheme.textSecondary(theme);
        final bgPrimary = AppColorScheme.backgroundPrimary(theme);
        final bgSecondary = AppColorScheme.backgroundSecondary(theme);

        return Container(
          padding: const EdgeInsets.only(top: 4, bottom: 4, left: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (index) {
              final dayNumber = index + 1;
              final isSelected = selectedDays.contains(dayNumber);

              return GestureDetector(
                onTap: () => onDayToggle(dayNumber),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected 
                        ? accentColor 
                        : bgSecondary.withOpacity(0.5),
                  ),
                  child: Center(
                    child: Text(
                      _dayLabels[index],
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected 
                            ? bgPrimary 
                            : textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
