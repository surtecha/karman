import 'package:flutter/cupertino.dart';
import 'package:karman_app/models/task/task.dart';
import 'package:karman_app/components/task/taskPageWidgets/priority_section.dart';
import 'package:karman_app/components/task/taskPageWidgets/completed_section.dart';

class TaskList extends StatelessWidget {
  final List<Task> tasks;
  final Map<int, bool> expandedSections;
  final Function(int) onToggleSection;
  final Function(Task) onTaskToggle;
  final Function(BuildContext, int) onTaskDelete;
  final Function(Task) onTaskTap; 

  const TaskList({
    super.key,
    required this.tasks,
    required this.expandedSections,
    required this.onToggleSection,
    required this.onTaskToggle,
    required this.onTaskDelete,
    required this.onTaskTap, 
  });

  @override
  Widget build(BuildContext context) {
    return tasks.isEmpty
        ? Center(
            child: Text(
              'This space craves your brilliant ideas. Add one!',
              style: TextStyle(
                fontSize: 18,
                color: CupertinoColors.systemGrey,
              ),
              textAlign: TextAlign.center,
            ),
          )
        : ListView(
            children: [
              PrioritySection(
                priority: 3,
                tasks: tasks,
                isExpanded: expandedSections[3]!,
                onToggle: onToggleSection,
                onTaskToggle: onTaskToggle,
                onTaskDelete: onTaskDelete,
                onTaskTap: onTaskTap, 
              ),
              PrioritySection(
                priority: 2,
                tasks: tasks,
                isExpanded: expandedSections[2]!,
                onToggle: onToggleSection,
                onTaskToggle: onTaskToggle,
                onTaskDelete: onTaskDelete,
                onTaskTap: onTaskTap, 
              ),
              PrioritySection(
                priority: 1,
                tasks: tasks,
                isExpanded: expandedSections[1]!,
                onToggle: onToggleSection,
                onTaskToggle: onTaskToggle,
                onTaskDelete: onTaskDelete,
                onTaskTap: onTaskTap, 
              ),
              CompletedSection(
                tasks: tasks,
                isExpanded: expandedSections[0]!,
                onToggle: () => onToggleSection(0),
                onTaskToggle: onTaskToggle,
                onTaskDelete: onTaskDelete,
                onTaskTap: onTaskTap, 
              ),
            ],
          );
  }
}
