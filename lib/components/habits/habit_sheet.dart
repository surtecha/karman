import 'package:flutter/cupertino.dart';
import 'package:karman/components/common/nav_button.dart';
import 'package:karman/components/todo/name_description_section.dart';
import 'package:karman/components/common/datetime_picker.dart';
import 'package:karman/components/common/custom_cupertino_switch.dart';
import 'package:karman/components/common/select_button.dart';
import 'package:karman/components/common/form_row_with_icon.dart';
import 'package:karman/components/common/repeat_day_selector.dart';
import 'package:karman/theme/color_scheme.dart';
import 'package:karman/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import '../../models/habit.dart';
import '../../providers/habit_provider.dart';

class HabitSheet extends StatefulWidget {
  final Habit? habit;

  const HabitSheet({super.key, this.habit});

  @override
  State<HabitSheet> createState() => _HabitSheetState();
}

class _HabitSheetState extends State<HabitSheet> {
  late final TextEditingController _nameController = TextEditingController();
  late final TextEditingController _descriptionController =
      TextEditingController();
  late final FocusNode _nameFocusNode = FocusNode();

  DateTime? _selectedTime;
  bool _customReminder = false;
  Set<int> _reminderDays = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    if (widget.habit != null) {
      _nameController.text = widget.habit!.name;
      _descriptionController.text = widget.habit!.description ?? '';
      _selectedTime = widget.habit!.reminder;
      _customReminder = widget.habit!.customReminder;
      _reminderDays = widget.habit!.reminderDays;
    } else {
      final now = DateTime.now();
      _selectedTime = DateTime(
        2000,
        1,
        1,
        now.hour + 1,
        0,
      );
    }

    // Add listener to rebuild UI when name changes
    _nameController.addListener(() {
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _nameFocusNode.requestFocus(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  void _showTimePicker(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder:
          (_) => DateTimePickerModal(
            initialDateTime: _selectedTime ?? DateTime.now(),
            mode: CupertinoDatePickerMode.time,
            use24hFormat: false,
            onChanged: (time) {
              setState(() => _selectedTime = time);
            },
          ),
    );
  }

  String _formatTime() {
    if (_selectedTime == null) return 'Select Time';
    
    final hour =
        _selectedTime!.hour == 0
            ? 12
            : _selectedTime!.hour > 12
            ? _selectedTime!.hour - 12
            : _selectedTime!.hour;
    final minute = _selectedTime!.minute.toString().padLeft(2, '0');
    final period = _selectedTime!.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _saveHabit() async {
    if (_nameController.text.trim().isEmpty || _selectedTime == null || _isSaving) {
      return;
    }

    setState(() => _isSaving = true);

    final habit = Habit(
      id: widget.habit?.id,
      name: _nameController.text.trim(),
      description:
          _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
      reminder: _selectedTime!,
      customReminder: _customReminder,
      reminderDays: _customReminder ? _reminderDays : {},
      currentStreak: widget.habit?.currentStreak ?? 0,
      maxStreak: widget.habit?.maxStreak ?? 0,
      lastCompletionDate: widget.habit?.lastCompletionDate,
      createdAt: widget.habit?.createdAt,
    );

    try {
      if (widget.habit != null) {
        await context.read<HabitProvider>().updateHabit(habit);
      } else {
        await context.read<HabitProvider>().addHabit(habit);
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
        final canSave = _nameController.text.trim().isNotEmpty && _selectedTime != null;
        
        return CupertinoPageScaffold(
          backgroundColor: AppColorScheme.backgroundSecondary(theme),
          navigationBar: CupertinoNavigationBar(
            backgroundColor: AppColorScheme.backgroundSecondary(theme),
            middle: Text(widget.habit != null ? 'Edit Habit' : 'New Habit'),
            leading: NavButton(
              icon: CupertinoIcons.xmark,
              color: AppColorScheme.surfaceElevated(theme),
              iconColor: AppColorScheme.textPrimary(theme),
              onPressed: () => Navigator.of(context).pop(),
            ),
            trailing:
                _isSaving
                    ? const CupertinoActivityIndicator()
                    : NavButton(
                      icon: CupertinoIcons.checkmark,
                      color:
                          canSave
                              ? AppColorScheme.accent(theme, context)
                              : AppColorScheme.surfaceElevated(theme),
                      iconColor:
                          canSave
                              ? AppColorScheme.backgroundPrimary(theme)
                              : AppColorScheme.textSecondary(theme),
                      onPressed: _saveHabit,
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
                      CupertinoFormSection.insetGrouped(
                        backgroundColor: AppColorScheme.backgroundSecondary(theme),
                        children: [
                          FormRowWithIcon(
                            icon: CupertinoIcons.time,
                            label: 'Time',
                            context: context,
                            child: SelectButton(
                              text: _formatTime(),
                              color: AppColorScheme.accent(theme, context),
                              onPressed: () => _showTimePicker(context),
                            ),
                          ),
                          FormRowWithIcon(
                            icon: CupertinoIcons.repeat,
                            label: 'Custom Reminder',
                            context: context,
                            child: CustomSwitch(
                              value: _customReminder,
                              onChanged: (value) {
                                setState(() {
                                  _customReminder = value;
                                  if (!value) {
                                    _reminderDays = {};
                                  }
                                });
                              },
                            ),
                          ),
                          if (_customReminder)
                            Container(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                              child: RepeatDaySelector(
                                selectedDays: _reminderDays,
                                onDayToggle: (day) {
                                  setState(() {
                                    if (_reminderDays.contains(day)) {
                                      _reminderDays.remove(day);
                                    } else {
                                      _reminderDays.add(day);
                                    }
                                  });
                                },
                              ),
                            ),
                        ],
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
