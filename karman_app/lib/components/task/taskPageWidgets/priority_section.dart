import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:karman_app/models/task/task.dart';
import 'package:karman_app/components/task/taskPageWidgets/task_tile.dart';

class PrioritySection extends StatefulWidget {
  final int priority;
  final List<Task> tasks;
  final bool isExpanded;
  final Function(int) onToggle;
  final Function(Task) onTaskToggle;
  final Function(BuildContext, int) onTaskDelete;
  final Function(Task) onTaskTap;

  const PrioritySection({
    super.key,
    required this.priority,
    required this.tasks,
    required this.isExpanded,
    required this.onToggle,
    required this.onTaskToggle,
    required this.onTaskDelete,
    required this.onTaskTap,
  });

  @override
  _PrioritySectionState createState() => _PrioritySectionState();
}

class _PrioritySectionState extends State<PrioritySection> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late List<Task> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = widget.tasks
        .where((task) => task.priority == widget.priority && !task.isCompleted)
        .toList();
  }

  @override
  void didUpdateWidget(PrioritySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateList();
  }

  void _updateList() {
    final newTasks = widget.tasks
        .where((task) => task.priority == widget.priority && !task.isCompleted)
        .toList();

    for (var i = 0; i < newTasks.length; i++) {
      if (i >= _tasks.length) {
        _tasks.add(newTasks[i]);
        _listKey.currentState?.insertItem(i);
      } else if (_tasks[i] != newTasks[i]) {
        _tasks[i] = newTasks[i];
        _listKey.currentState?.setState(() {});
      }
    }

    while (_tasks.length > newTasks.length) {
      final task = _tasks.removeLast();
      _listKey.currentState?.removeItem(
        _tasks.length,
        (context, animation) => _buildItem(context, task, animation),
      );
    }
  }

  Widget _buildItem(
      BuildContext context, Task task, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: TaskTile(
        key: ValueKey(task.taskId),
        task: task,
        onChanged: (value) => widget.onTaskToggle(task),
        onDelete: (context) => widget.onTaskDelete(context, task.taskId!),
        onTap: () => widget.onTaskTap(task),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_tasks.isEmpty) {
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
                      ? Colors.red
                      : (widget.priority == 2 ? Colors.yellow : Colors.green),
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
          AnimatedList(
            key: _listKey,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            initialItemCount: _tasks.length,
            itemBuilder: (context, index, animation) {
              return _buildItem(context, _tasks[index], animation);
            },
          ),
        SizedBox(height: 16),
      ],
    );
  }
}
