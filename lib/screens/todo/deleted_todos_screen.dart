import 'package:flutter/cupertino.dart';
import 'package:karman/components/common/context_menu.dart';
import 'package:karman/components/common/multi_selector.dart';
import 'package:karman/components/todo/delete_confirmation_dialog.dart';
import 'package:karman/components/todo/todo_tile.dart';
import 'package:karman/theme/color_scheme.dart';
import 'package:karman/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import '../../providers/todo_provider.dart';

class DeletedTodosScreen extends StatefulWidget {
  const DeletedTodosScreen({super.key});

  @override
  State<DeletedTodosScreen> createState() => _DeletedTodosScreenState();
}

class _DeletedTodosScreenState extends State<DeletedTodosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodoProvider>().loadDeletedTodos();
    });
  }

  void _handleRestore(BuildContext context, TodoProvider todoProvider) async {
    if (todoProvider.selectedDeletedTodoIds.isEmpty) return;
    await todoProvider.restoreSelectedTodos();
  }

  void _handleDelete(BuildContext context, TodoProvider todoProvider) async {
    if (todoProvider.selectedDeletedTodoIds.isEmpty) return;

    DeleteConfirmationDialog.showPermanentDelete(
      context,
      onConfirm: () => todoProvider.permanentlyDeleteSelectedTodos(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, TodoProvider>(
      builder: (context, theme, todoProvider, child) {
        return CupertinoPageScaffold(
          backgroundColor: AppColorScheme.backgroundPrimary(theme),
          navigationBar: CupertinoNavigationBar(
            backgroundColor: AppColorScheme.backgroundPrimary(theme),
            middle: const Text('Deleted'),
            leading: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Icon(
                CupertinoIcons.chevron_left_circle,
                color: AppColorScheme.accent(theme, context),
              ),
            ),
            trailing: !todoProvider.isDeletedSelectionMode
                ? ContextMenu(
                    alignment: Alignment.topRight,
                    items: [
                      ContextMenuItem(
                        icon: CupertinoIcons.checkmark_circle,
                        iconColor: AppColorScheme.accent(theme, context),
                        label: 'Select',
                        onTap: () => todoProvider.toggleDeletedSelectionMode(),
                      ),
                      ContextMenuItem(
                        icon: CupertinoIcons.checkmark_alt_circle_fill,
                        iconColor: AppColorScheme.accent(theme, context),
                        label: 'Select All',
                        onTap: () {
                          todoProvider.toggleDeletedSelectionMode();
                          for (var todo in todoProvider.deletedTodos) {
                            if (!todoProvider.isDeletedTodoSelected(todo.id!)) {
                              todoProvider.toggleDeletedTodoSelection(todo.id!);
                            }
                          }
                        },
                      ),
                    ],
                    child: Icon(
                      CupertinoIcons.ellipsis_circle,
                      size: 28,
                      color: AppColorScheme.accent(theme, context),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: todoProvider.selectedDeletedTodoIds.isEmpty
                            ? null
                            : () => _handleRestore(context, todoProvider),
                        child: Icon(
                          CupertinoIcons.arrow_counterclockwise,
                          size: 28,
                          color: todoProvider.selectedDeletedTodoIds.isEmpty
                              ? AppColorScheme.textSecondary(theme)
                              : AppColorScheme.accent(theme, context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: todoProvider.selectedDeletedTodoIds.isEmpty
                            ? null
                            : () => _handleDelete(context, todoProvider),
                        child: Icon(
                          CupertinoIcons.trash,
                          size: 28,
                          color: todoProvider.selectedDeletedTodoIds.isEmpty
                              ? AppColorScheme.textSecondary(theme)
                              : AppColorScheme.destructive(context),
                        ),
                      ),
                    ],
                  ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                MultiSelector<int>(
                  isActive: todoProvider.isDeletedSelectionMode,
                  selectedItems: todoProvider.selectedDeletedTodoIds,
                  onToggleMode: todoProvider.toggleDeletedSelectionMode,
                  onDelete: () => _handleDelete(context, todoProvider),
                ),
                Expanded(
                  child: todoProvider.deletedTodos.isEmpty
                      ? const Center(
                          child: Text(
                            'No deleted todos',
                            style: TextStyle(
                              fontSize: 18,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: todoProvider.deletedTodos.length,
                          itemBuilder: (context, index) {
                            final todo = todoProvider.deletedTodos[index];
                            final isSelected = todoProvider.isDeletedTodoSelected(todo.id!);

                            return TodoTile(
                              todo: todo,
                              onTap: () {
                                if (todoProvider.isDeletedSelectionMode) {
                                  todoProvider.toggleDeletedTodoSelection(todo.id!);
                                }
                              },
                              onToggle: (completed) {
                                if (todoProvider.isDeletedSelectionMode) {
                                  todoProvider.toggleDeletedTodoSelection(todo.id!);
                                }
                              },
                              onDelete: () {},
                              isSelected: isSelected,
                              isSelectionMode: todoProvider.isDeletedSelectionMode,
                              showPriorityBorder: true,
                              enableSwipeToDelete: false,
                              showCompletionCheckbox: false,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
