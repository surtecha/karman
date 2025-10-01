import 'package:flutter/cupertino.dart';
import 'package:karman/theme/color_scheme.dart';
import 'package:karman/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import '../../providers/todo_provider.dart';

class TodoContextMenu {
  static void show(
    BuildContext context,
    TodoProvider todoProvider, {
    required VoidCallback onDeletedItemsTap,
  }) {
    final theme = Provider.of<ThemeProvider>(context, listen: false);

    showCupertinoModalPopup(
      context: context,
      builder:
          (BuildContext context) => CupertinoActionSheet(
            actions: [
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  todoProvider.toggleSelectionMode();
                },
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.checkmark_circle,
                      color: AppColorScheme.accent(theme, context),
                      size: 22,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Select',
                        style: TextStyle(
                          fontSize: 17,
                          color: AppColorScheme.textPrimary(theme),
                        ),
                      ),
                    ),
                    Icon(
                      CupertinoIcons.chevron_right,
                      color: AppColorScheme.textSecondary(theme),
                      size: 18,
                    ),
                  ],
                ),
              ),
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  todoProvider.toggleSelectionMode();
                  // Select all current todos
                  for (var todo in todoProvider.currentTodos) {
                    if (!todoProvider.isTodoSelected(todo.id!)) {
                      todoProvider.toggleTodoSelection(todo.id!);
                    }
                  }
                },
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.checkmark_alt_circle_fill,
                      color: AppColorScheme.accent(theme, context),
                      size: 22,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Select All',
                        style: TextStyle(
                          fontSize: 17,
                          color: AppColorScheme.textPrimary(theme),
                        ),
                      ),
                    ),
                    Icon(
                      CupertinoIcons.chevron_right,
                      color: AppColorScheme.textSecondary(theme),
                      size: 18,
                    ),
                  ],
                ),
              ),
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  onDeletedItemsTap();
                },
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.trash,
                      color: AppColorScheme.destructive(context),
                      size: 22,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Deleted Items',
                        style: TextStyle(
                          fontSize: 17,
                          color: AppColorScheme.textPrimary(theme),
                        ),
                      ),
                    ),
                    Icon(
                      CupertinoIcons.chevron_right,
                      color: AppColorScheme.textSecondary(theme),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColorScheme.textPrimary(theme)),
              ),
            ),
          ),
    );
  }
}
