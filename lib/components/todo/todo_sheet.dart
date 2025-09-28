import 'package:flutter/cupertino.dart';
import 'package:karman/theme/color_scheme.dart';
import 'package:karman/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:karman/components/common/nav_button.dart';
import 'package:karman/components/todo/name_description_section.dart';
import 'package:karman/components/todo/reminder_section.dart';

class TodoSheet extends StatefulWidget {
  const TodoSheet({super.key});

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _nameFocusNode.requestFocus());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, child) {
        return CupertinoPageScaffold(
          backgroundColor: AppColorScheme.backgroundSecondary(theme),
          navigationBar: CupertinoNavigationBar(
            backgroundColor: AppColorScheme.backgroundSecondary(theme),
            middle: const Text('New Todo'),
            leading: NavButton(
              icon: CupertinoIcons.xmark,
              color: AppColorScheme.surfaceElevated(theme),
              iconColor: AppColorScheme.textPrimary(theme),
              onPressed: Navigator.of(context).pop,
            ),
            trailing: NavButton(
              icon: CupertinoIcons.checkmark,
              color: AppColorScheme.accent(theme, context),
              iconColor: AppColorScheme.backgroundPrimary(theme),
              onPressed: Navigator.of(context).pop,
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
                        onReminderToggle: (value) => setState(() => _hasReminder = value),
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