import 'package:flutter/cupertino.dart';
import 'package:karman/theme/color_scheme.dart';
import 'package:karman/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:karman/components/todo/todo_list.dart';
import '../../providers/todo_provider.dart';

class CompletedTodosScreen extends StatelessWidget {
  const CompletedTodosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, TodoProvider>(
      builder: (context, theme, todoProvider, child) {
        return CupertinoPageScaffold(
          backgroundColor: AppColorScheme.backgroundPrimary(theme),
          navigationBar: CupertinoNavigationBar(
            backgroundColor: AppColorScheme.backgroundPrimary(theme),
            middle: Text('Completed'),
            leading: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Icon(
                CupertinoIcons.chevron_left_circle,
                color: AppColorScheme.accent(theme, context),
              ),
            ),
          ),
          child: SafeArea(
            child: todoProvider.isLoading
                ? const Center(child: CupertinoActivityIndicator())
                : CustomScrollView(
              slivers: [
                TodoList(
                  todos: todoProvider.completedTodos,
                  onTodoTap: (todo) {},
                  onTodoToggle: (todo, completed) => todoProvider.toggleTodo(todo),
                  onTodoDelete: (todo) => todoProvider.deleteTodo(todo),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}