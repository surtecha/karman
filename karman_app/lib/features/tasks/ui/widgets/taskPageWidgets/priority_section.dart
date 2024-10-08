import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:karman_app/features/tasks/data/task.dart';
import 'package:karman_app/features/tasks/ui/widgets/taskPageWidgets/task_tile.dart';

class PrioritySection extends StatefulWidget {
  final int priority;
  final List<Task> tasks;
  final bool isExpanded;
  final Function(int) onToggle;
  final Function(Task) onTaskToggle;
  final Function(BuildContext, int) onTaskDelete;
  final Function(Task) onTaskTap;
  final Function(int, Task, int) onTaskReorder;

  const PrioritySection({
    super.key,
    required this.priority,
    required this.tasks,
    required this.isExpanded,
    required this.onToggle,
    required this.onTaskToggle,
    required this.onTaskDelete,
    required this.onTaskTap,
    required this.onTaskReorder,
  });

  @override
  _PrioritySectionState createState() => _PrioritySectionState();
}

class _PrioritySectionState extends State<PrioritySection> {
  late List<Task> _priorityTasks;

  @override
  void initState() {
    super.initState();
    _updatePriorityTasks();
  }

  @override
  void didUpdateWidget(PrioritySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tasks != widget.tasks ||
        oldWidget.priority != widget.priority) {
      _updatePriorityTasks();
    }
  }

  void _updatePriorityTasks() {
    _priorityTasks = widget.tasks
        .where((task) => task.priority == widget.priority && !task.isCompleted)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  @override
  Widget build(BuildContext context) {
    if (_priorityTasks.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => widget.onToggle(widget.priority),
          child: Container(
            padding: EdgeInsets.only(
              top: 23,
              left: 8,
              right: 8,
              bottom: 13,
            ),
            color: CupertinoColors.black,
            child: Row(
              children: [
                Icon(
                  size: 32,
                  widget.isExpanded
                      ? CupertinoIcons.flag_circle
                      : CupertinoIcons.flag_circle_fill,
                  color: widget.priority == 3
                      ? CupertinoColors.systemRed
                      : (widget.priority == 2
                          ? CupertinoColors.systemYellow
                          : CupertinoColors.systemGreen),
                ),
                SizedBox(width: 10),
                Text(
                  widget.priority == 3
                      ? 'High'
                      : (widget.priority == 2 ? 'Medium' : 'Low'),
                  style: TextStyle(
                      color: CupertinoColors.white,
                      fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Icon(
                  widget.isExpanded
                      ? CupertinoIcons.chevron_up
                      : CupertinoIcons.chevron_down,
                  color: CupertinoColors.white,
                ),
              ],
            ),
          ),
        ),
        if (widget.isExpanded)
          Material(
            color: Colors.transparent,
            child: Localizations(
              locale: const Locale('en', 'US'),
              delegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              child: _priorityTasks.length > 1
                  ? ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _priorityTasks.length,
                      itemBuilder: (context, index) {
                        final task = _priorityTasks[index];
                        return TaskTile(
                          key: ValueKey(task.taskId),
                          task: task,
                          onChanged: (value) => widget.onTaskToggle(task),
                          onDelete: (context) =>
                              widget.onTaskDelete(context, task.taskId!),
                          onTap: () => widget.onTaskTap(task),
                          showReorderIcon: true,
                        );
                      },
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (oldIndex < newIndex) {
                            newIndex -= 1;
                          }
                          final Task task = _priorityTasks.removeAt(oldIndex);
                          _priorityTasks.insert(newIndex, task);
                          widget.onTaskReorder(widget.priority, task, newIndex);
                        });
                      },
                      proxyDecorator: (child, index, animation) {
                        return AnimatedBuilder(
                          animation: animation,
                          builder: (BuildContext context, Widget? child) {
                            final double animValue =
                                Curves.easeInOut.transform(animation.value);
                            final double elevation =
                                lerpDouble(0, 6, animValue)!;
                            return Material(
                              elevation: elevation,
                              color: Colors.black.withOpacity(0.5),
                              shadowColor: Colors.black54,
                              child: child,
                            );
                          },
                          child: child,
                        );
                      },
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _priorityTasks.length,
                      itemBuilder: (context, index) {
                        final task = _priorityTasks[index];
                        return TaskTile(
                          key: ValueKey(task.taskId),
                          task: task,
                          onChanged: (value) => widget.onTaskToggle(task),
                          onDelete: (context) =>
                              widget.onTaskDelete(context, task.taskId!),
                          onTap: () => widget.onTaskTap(task),
                          showReorderIcon: false,
                        );
                      },
                    ),
            ),
          ),
        SizedBox(height: 16)
      ],
    );
  }
}
