import 'package:flutter/cupertino.dart';
import 'package:karman/theme/color_scheme.dart';
import 'package:karman/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class PrioritySelector extends StatelessWidget {
  final int selectedPriority;
  final Function(int) onPriorityChanged;

  const PrioritySelector({
    super.key,
    required this.selectedPriority,
    required this.onPriorityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, child) {
        final bgPrimary = AppColorScheme.backgroundPrimary(theme);
        final bgSecondary = AppColorScheme.backgroundSecondary(theme);
        final textPrimary = AppColorScheme.textPrimary(theme);

        return CupertinoFormSection.insetGrouped(
          backgroundColor: bgSecondary,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.flag,
                    size: 24,
                    color: textPrimary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Priority',
                    style: TextStyle(
                      fontSize: 16,
                      color: textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildPriorityButton(
                        context,
                        theme,
                        0,
                        AppColorScheme.accentColors['green']!.resolveFrom(context),
                        bgPrimary,
                        bgSecondary,
                        textPrimary,
                      ),
                      const SizedBox(width: 12),
                      _buildPriorityButton(
                        context,
                        theme,
                        1,
                        AppColorScheme.accentColors['orange']!.resolveFrom(context),
                        bgPrimary,
                        bgSecondary,
                        textPrimary,
                      ),
                      const SizedBox(width: 12),
                      _buildPriorityButton(
                        context,
                        theme,
                        2,
                        AppColorScheme.destructive(context),
                        bgPrimary,
                        bgSecondary,
                        textPrimary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPriorityButton(
    BuildContext context,
    ThemeProvider theme,
    int priority,
    Color priorityColor,
    Color bgPrimary,
    Color bgSecondary,
    Color textPrimary,
  ) {
    final isSelected = selectedPriority == priority;

    return GestureDetector(
      onTap: () => onPriorityChanged(priority),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? priorityColor : bgSecondary.withOpacity(0.5),
        ),
        child: Center(
          child: Icon(
            CupertinoIcons.flag_fill,
            size: 18,
            color: isSelected ? bgPrimary : priorityColor,
          ),
        ),
      ),
    );
  }
}
