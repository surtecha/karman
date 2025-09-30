import 'package:flutter/cupertino.dart';
import 'package:karman/theme/color_scheme.dart';
import 'package:karman/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:karman/components/common/nav_button.dart';
import 'package:karman/components/todo/name_description_section.dart';
import 'package:karman/components/todo/reminder_section.dart';
import '../../models/todo.dart';
import '../../providers/todo_provider.dart';

class TodoSheet extends StatefulWidget {
  final Todo? todo;

  const TodoSheet({super.key, this.todo});

  @override
  State<TodoSheet> createState() => _TodoSheetState();
}

class _TodoSheetState extends State<TodoSheet> {
  late final TextEditingController _nameController = TextEditingController();
  late final TextEditingController _descriptionController = TextEditingController();
  late final FocusNode _nameFocusNode = FocusNode();

  bool _hasReminder = false;
  DateTime? _selectedDate;
  DateTime? _selectedTime;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    if (widget.todo != null) {
      _nameController.text = widget.todo!.name;
      _descriptionController.text = widget.todo!.description ?? '';
      _hasReminder = widget.todo!.reminder != null;
      if (widget.todo!.reminder != null) {
        _selectedDate = widget.todo!.reminder;
        _selectedTime = widget.todo!.reminder;
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _nameFocusNode.requestFocus());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  DateTime? _getCombinedDateTime() {
    if (!_hasReminder || _selectedDate == null || _selectedTime == null) {
      return null;
    }

    return DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
  }

  Future<void> _saveTodo() async {
    if (_nameController.text.trim().isEmpty || _isSaving) return;

    setState(() => _isSaving = true);

    final todo = Todo(
      id: widget.todo?.id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      reminder: _getCombinedDateTime(),
      completed: widget.todo?.completed ?? false,
    );

    try {
      if (widget.todo != null) {
        await context.read<TodoProvider>().updateTodoDirectly(todo);
      } else {
        await context.read<TodoProvider>().addTodo(todo);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, child) {
        return CupertinoPageScaffold(
          backgroundColor: AppColorScheme.backgroundSecondary(theme),
          navigationBar: CupertinoNavigationBar(
            backgroundColor: AppColorScheme.backgroundSecondary(theme),
            middle: Text(widget.todo != null ? 'Edit Todo' : 'New Todo'),
            leading: NavButton(
              icon: CupertinoIcons.xmark,
              color: AppColorScheme.surfaceElevated(theme),
              iconColor: AppColorScheme.textPrimary(theme),
              onPressed: () => Navigator.of(context).pop(),
            ),
            trailing: _isSaving
                ? const CupertinoActivityIndicator()
                : NavButton(
              icon: CupertinoIcons.checkmark,
              color: _nameController.text.trim().isEmpty
                  ? AppColorScheme.surfaceElevated(theme)
                  : AppColorScheme.accent(theme, context),
              iconColor: _nameController.text.trim().isEmpty
                  ? AppColorScheme.textSecondary(theme)
                  : AppColorScheme.backgroundPrimary(theme),
              onPressed: _saveTodo,
            ),
          ),
          child: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.only(top: 20),
                  sliver: SliverList.list(
                    children: [
                      NameDescriptionSection(
                        nameController: _nameController,
                        descriptionController: _descriptionController,
                        nameFocusNode: _nameFocusNode,
                      ),
                      const SizedBox(height: 10),
                      ReminderSection(
                        hasReminder: _hasReminder,
                        selectedDate: _selectedDate,
                        selectedTime: _selectedTime,
                        onReminderToggle: (value) {
                          setState(() {
                            _hasReminder = value;
                            if (value && _selectedDate == null) {
                              _selectedDate = DateTime.now();
                            }
                            if (value && _selectedTime == null) {
                              final now = DateTime.now();
                              _selectedTime = DateTime(2000, 1, 1, now.hour + 1, 0);
                            }
                          });
                        },
                        onDateChanged: (date) => setState(() => _selectedDate = date),
                        onTimeChanged: (time) => setState(() => _selectedTime = time),
                      ),
                    ],
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