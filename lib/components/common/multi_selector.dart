import 'package:flutter/cupertino.dart';
import 'package:karman/theme/color_scheme.dart';
import 'package:karman/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class MultiSelector<T> extends StatelessWidget {
  final bool isActive;
  final Set<T> selectedItems;
  final VoidCallback onToggleMode;
  final VoidCallback onDelete;
  final String Function(int count)? selectionText;

  const MultiSelector({
    super.key,
    required this.isActive,
    required this.selectedItems,
    required this.onToggleMode,
    required this.onDelete,
    this.selectionText,
  });

  String _defaultSelectionText(int count) {
    return '$count selected';
  }

  @override
  Widget build(BuildContext context) {
    if (!isActive) return const SizedBox.shrink();

    final theme = context.watch<ThemeProvider>();
    final textGenerator = selectionText ?? _defaultSelectionText;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      color: AppColorScheme.accent(theme, context).withOpacity(0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            textGenerator(selectedItems.length),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColorScheme.accent(theme, context),
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onToggleMode,
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColorScheme.accent(theme, context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MultiSelectorNavButton extends StatelessWidget {
  final bool isSelectionMode;
  final bool hasSelectedItems;
  final VoidCallback onPressed;
  final IconData activeIcon;
  final IconData inactiveIcon;

  const MultiSelectorNavButton({
    super.key,
    required this.isSelectionMode,
    required this.hasSelectedItems,
    required this.onPressed,
    this.activeIcon = CupertinoIcons.trash,
    this.inactiveIcon = CupertinoIcons.checkmark_circle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Icon(
        isSelectionMode ? activeIcon : inactiveIcon,
        size: 28,
        color: isSelectionMode && !hasSelectedItems
            ? AppColorScheme.textSecondary(theme)
            : AppColorScheme.accent(theme, context),
      ),
    );
  }
}