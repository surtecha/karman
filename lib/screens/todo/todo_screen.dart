import 'package:flutter/cupertino.dart';
import 'package:karman/components/common/floating_action_button.dart';
import 'package:karman/components/common/multi_selector.dart';
import 'package:karman/components/todo/delete_confirmation_dialog.dart';
import 'package:karman/components/todo/todo_context_menu.dart';
import 'package:karman/theme/color_scheme.dart';
import 'package:karman/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:karman/components/pill_button.dart';
import 'package:karman/components/todo/todo_sheet.dart';
import 'package:karman/components/todo/todo_list.dart';
import '../../providers/todo_provider.dart';
import 'completed_todo_screen.dart';
import 'deleted_todos_screen.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodoProvider>().loadTodos();
    });
  }

  void _openTodoSheet(BuildContext context, {todo}) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => TodoSheet(todo: todo),
    );
  }

  void _openCompletedTodos(BuildContext context) {
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (context) => const CompletedTodosScreen()),
    );
  }

  void _openDeletedTodos(BuildContext context) {
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (context) => const DeletedTodosScreen()),
    );
  }

  void _handleDelete(BuildContext context, TodoProvider todoProvider) async {
    if (todoProvider.selectedTodoIds.isEmpty) return;

    DeleteConfirmationDialog.show(
      context,
      count: todoProvider.selectedTodoIds.length,
      onConfirm: () => todoProvider.deleteSelectedTodos(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, TodoProvider>(
      builder: (context, theme, todoProvider, child) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            backgroundColor: AppColorScheme.backgroundPrimary(theme),
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed:
                  () => TodoContextMenu.show(
                    context,
                    todoProvider,
                    onDeletedItemsTap: () => _openDeletedTodos(context),
                  ),
              child: Icon(
                CupertinoIcons.ellipsis_circle,
                size: 28,
                color: AppColorScheme.accent(theme, context),
              ),
            ),
            trailing: MultiSelectorNavButton(
              isSelectionMode: todoProvider.isSelectionMode,
              hasSelectedItems: todoProvider.selectedTodoIds.isNotEmpty,
              onPressed:
                  todoProvider.isSelectionMode
                      ? () => _handleDelete(context, todoProvider)
                      : () => _openCompletedTodos(context),
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    Column(
                      children: [
                        MultiSelector<int>(
                          isActive: todoProvider.isSelectionMode,
                          selectedItems: todoProvider.selectedTodoIds,
                          onToggleMode: todoProvider.toggleSelectionMode,
                          onDelete: () => _handleDelete(context, todoProvider),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: PillButton(
                            options: const ['Today', 'Scheduled', 'Decide'],
                            counts: [
                              todoProvider.todayTodos.length,
                              todoProvider.scheduledTodos.length,
                              todoProvider.decideTodos.length,
                            ],
                            onSelectionChanged: todoProvider.setSelectedIndex,
                            initialSelection: todoProvider.selectedIndex,
                          ),
                        ),
                        Expanded(
                          child:
                              todoProvider.isLoading
                                  ? const Center(
                                    child: CupertinoActivityIndicator(),
                                  )
                                  : CustomScrollView(
                                    slivers: [
                                      TodoList(
                                        todos: todoProvider.currentTodos,
                                        onTodoTap:
                                            (todo) => _openTodoSheet(
                                              context,
                                              todo: todo,
                                            ),
                                        onTodoToggle:
                                            (todo, completed) =>
                                                todoProvider.toggleTodo(todo),
                                        onTodoDelete:
                                            (todo) =>
                                                todoProvider.deleteTodo(todo),
                                        onReorder:
                                            (oldIndex, newIndex) =>
                                                todoProvider.reorderTodos(
                                                  oldIndex,
                                                  newIndex,
                                                ),
                                      ),
                                    ],
                                  ),
                        ),
                      ],
                    ),
                    if (!todoProvider.isSelectionMode)
                      Positioned(
                        bottom: constraints.maxHeight > 600 ? 20 : 16,
                        right: constraints.maxWidth < 350 ? 16 : 20,
                        child: CustomFloatingActionButton(
                          onPressed: () => _openTodoSheet(context),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
