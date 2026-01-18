import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:karman/theme/color_scheme.dart';
import 'package:karman/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import '../../models/todo.dart';
import '../../providers/todo_provider.dart';
import 'todo_tile.dart';

class TodoList extends StatelessWidget {
  final List<Todo> todos;
  final Function(Todo) onTodoTap;
  final Function(Todo, bool) onTodoToggle;
  final Function(Todo) onTodoDelete;
  final Function(int, int)? onReorder;
  final bool showPriorityBorder;

  const TodoList({
    super.key,
    required this.todos,
    required this.onTodoTap,
    required this.onTodoToggle,
    required this.onTodoDelete,
    this.onReorder,
    this.showPriorityBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    if (todos.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Text(
            'No todos yet',
            style: TextStyle(fontSize: 18, color: CupertinoColors.systemGrey),
          ),
        ),
      );
    }

    return Consumer2<ThemeProvider, TodoProvider>(
      builder: (context, theme, todoProvider, child) {
        return SliverToBoxAdapter(
          child: Material(
            color: Colors.transparent,
            child: Localizations(
              locale: const Locale('en', 'US'),
              delegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              child: ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: todos.length,
                itemBuilder: (context, index) {
                  final todo = todos[index];
                  return Container(
                    key: ValueKey(todo.id),
                    child: TodoTile(
                      todo: todo,
                      onTap: () => onTodoTap(todo),
                      onToggle: (completed) {
                        if (todoProvider.isSelectionMode) {
                          todoProvider.toggleTodoSelection(todo.id!);
                        } else {
                          onTodoToggle(todo, completed ?? false);
                        }
                      },
                      onDelete: () => onTodoDelete(todo),
                      isSelected: todoProvider.isTodoSelected(todo.id!),
                      isSelectionMode: todoProvider.isSelectionMode,
                      showPriorityBorder: showPriorityBorder,
                    ),
                  );
                },
                onReorder: (oldIndex, newIndex) {
                  if (oldIndex < newIndex) newIndex -= 1;
                  HapticFeedback.lightImpact();
                  onReorder?.call(oldIndex, newIndex);
                },
                proxyDecorator: (child, index, animation) {
                  return AnimatedBuilder(
                    animation: animation,
                    builder: (context, child) {
                      final animValue = Curves.fastOutSlowIn.transform(
                        animation.value,
                      );
                      return Transform.scale(
                        scale: 1.0 + (animValue * 0.05),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColorScheme.backgroundPrimary(theme),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: AppColorScheme.shadow(theme),
                                blurRadius: animValue * 8,
                                offset: Offset(0, animValue * 4),
                              ),
                            ],
                          ),
                          child: child,
                        ),
                      );
                    },
                    child: child,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
