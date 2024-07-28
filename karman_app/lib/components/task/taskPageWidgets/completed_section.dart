import 'package:flutter/cupertino.dart';
import 'package:karman_app/models/task/task.dart';
import 'package:karman_app/components/task/taskPageWidgets/task_tile.dart';

class CompletedSection extends StatefulWidget {
  final List<Task> tasks;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Function(Task) onTaskToggle;
  final Function(BuildContext, int) onTaskDelete;
  final Function(Task) onTaskTap;

  const CompletedSection({
    super.key,
    required this.tasks,
    required this.isExpanded,
    required this.onToggle,
    required this.onTaskToggle,
    required this.onTaskDelete,
    required this.onTaskTap,
  });

  @override
  _CompletedSectionState createState() => _CompletedSectionState();
}

class _CompletedSectionState extends State<CompletedSection> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late List<Task> _completedTasks;

  @override
  void initState() {
    super.initState();
    _completedTasks = widget.tasks.where((task) => task.isCompleted).toList();
  }

  @override
  void didUpdateWidget(CompletedSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateList();
  }

  void _updateList() {
    final newCompletedTasks =
        widget.tasks.where((task) => task.isCompleted).toList();

    for (var i = 0; i < newCompletedTasks.length; i++) {
      if (i >= _completedTasks.length) {
        _completedTasks.add(newCompletedTasks[i]);
        _listKey.currentState?.insertItem(i);
      } else if (_completedTasks[i] != newCompletedTasks[i]) {
        _completedTasks[i] = newCompletedTasks[i];
        _listKey.currentState?.setState(() {});
      }
    }

    while (_completedTasks.length > newCompletedTasks.length) {
      final task = _completedTasks.removeLast();
      _listKey.currentState?.removeItem(
        _completedTasks.length,
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
    if (_completedTasks.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: widget.onToggle,
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
                      ? CupertinoIcons.checkmark_circle
                      : CupertinoIcons.checkmark_circle_fill,
                  color: CupertinoColors.systemGrey,
                ),
                SizedBox(width: 10),
                Text(
                  'Completed',
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
            initialItemCount: _completedTasks.length,
            itemBuilder: (context, index, animation) {
              return _buildItem(context, _completedTasks[index], animation);
            },
          ),
      ],
    );
  }
}
