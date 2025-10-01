import 'package:flutter/cupertino.dart';
import 'package:karman/theme/color_scheme.dart';
import 'package:karman/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class DeleteConfirmationDialog {
  static void show(
    BuildContext context, {
    required int count,
    required VoidCallback onConfirm,
  }) {
    final theme = Provider.of<ThemeProvider>(context, listen: false);

    showCupertinoDialog(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: Text(
              'Delete Selected',
              style: TextStyle(color: AppColorScheme.textPrimary(theme)),
            ),
            content: Text(
              'Delete $count todo(s)?',
              style: TextStyle(color: AppColorScheme.textSecondary(theme)),
            ),
            actions: [
              CupertinoDialogAction(
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppColorScheme.accent(theme, context),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.pop(context);
                  onConfirm();
                },
                child: Text(
                  'Delete',
                  style: TextStyle(color: AppColorScheme.destructive(context)),
                ),
              ),
            ],
          ),
    );
  }

  static void showPermanentDelete(
    BuildContext context, {
    required VoidCallback onConfirm,
  }) {
    final theme = Provider.of<ThemeProvider>(context, listen: false);

    showCupertinoDialog(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: Text(
              'Delete Permanently',
              style: TextStyle(color: AppColorScheme.textPrimary(theme)),
            ),
            content: Text(
              'This action cannot be undone. Are you sure?',
              style: TextStyle(color: AppColorScheme.textSecondary(theme)),
            ),
            actions: [
              CupertinoDialogAction(
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppColorScheme.accent(theme, context),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.pop(context);
                  onConfirm();
                },
                child: Text(
                  'Delete',
                  style: TextStyle(color: AppColorScheme.destructive(context)),
                ),
              ),
            ],
          ),
    );
  }
}
