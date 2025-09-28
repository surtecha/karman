import 'package:flutter/cupertino.dart';
import 'package:karman/components/common/floating_action_button.dart';
import 'package:karman/theme/color_scheme.dart';
import 'package:karman/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:karman/components/pill_button.dart';
import 'package:karman/components/todo/todo_sheet.dart';

class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  void _openTodoSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => TodoSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, child) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {

              },
              child: Icon(
                CupertinoIcons.ellipsis_circle,
                size: 28,
                color: AppColorScheme.accent(theme, context),
              ),
            ),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {

              },
              child: Icon(
                CupertinoIcons.checkmark_circle,
                size: 28,
                color: AppColorScheme.accent(theme, context),
              ),
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: PillButton(
                            options: ['Today', 'Scheduled', 'Decide'],
                            counts: [5, 12, 8],
                            onSelectionChanged: (index) {

                            },
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              'Todo Page',
                              style: TextStyle(
                                fontSize: 24,
                                color: AppColorScheme.textPrimary(theme),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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