import 'package:flutter/cupertino.dart';
import 'package:karman/components/todo/delete_confirmation_dialog.dart';
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
          ),
          child: SafeArea(
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
                return Container(
                  color: AppColorScheme.backgroundPrimary(theme),
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    onPressed: () {},
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                todo.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColorScheme.textPrimary(theme),
                                ),
                              ),
                              if (todo.description?.isNotEmpty == true) ...[
                                const SizedBox(height: 4),
                                Text(
                                  todo.description!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColorScheme.textSecondary(theme),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () async {
                            await todoProvider.restoreTodo(todo.id!);
                          },
                          child: Icon(
                            CupertinoIcons.arrow_counterclockwise,
                            color: AppColorScheme.accent(theme, context),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 8),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            DeleteConfirmationDialog.showPermanentDelete(
                              context,
                              onConfirm: () => todoProvider.permanentlyDeleteTodo(todo.id!),
                            );
                          },
                          child: Icon(
                            CupertinoIcons.delete,
                            color: AppColorScheme.destructive(context),
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}