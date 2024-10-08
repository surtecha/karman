import 'package:flutter/cupertino.dart';
import 'package:karman_app/core/components/fab/minimal_floating_action_button.dart';
import 'package:karman_app/features/tasks/data/task.dart';
import 'package:karman_app/features/tasks/logic/task_controller.dart';
import 'package:karman_app/features/tasks/ui/pages/task_details_sheet.dart';
import 'package:karman_app/features/tasks/ui/widgets/taskPageWidgets/task_list.dart';
import 'package:karman_app/features/welcome_tutorial/ui/pages/tutorial/task_tutorial.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  TasksPageState createState() => TasksPageState();
}

class TasksPageState extends State<TasksPage> with TickerProviderStateMixin {
  List<Task> _sortedTasks = [];
  final Map<int, bool> _expandedSections = {1: true, 2: true, 3: true, 0: true};
  bool _showTutorial = false;
  late AnimationController _tutorialAnimationController;
  late Animation<double> _tutorialFadeAnimation;

  @override
  void initState() {
    super.initState();
    _tutorialAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _tutorialFadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(_tutorialAnimationController);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskController>().loadTasks();
      _checkFirstLaunch();
    });
  }

  @override
  void dispose() {
    _tutorialAnimationController.dispose();
    super.dispose();
  }

  Future<void> _checkFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('first_launch') ?? true;
    if (isFirstLaunch) {
      await Future.delayed(Duration(milliseconds: 200));
      setState(() {
        _showTutorial = true;
      });
      _tutorialAnimationController.forward();
    }
  }

  void _onTutorialComplete() async {
    await _tutorialAnimationController.reverse();
    setState(() {
      _showTutorial = false;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_launch', false);
  }

  void _sortTasks(List<Task> tasks, TaskController taskController) {
    _sortedTasks = List.from(tasks);
    _sortedTasks.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      if (a.priority != b.priority) {
        return b.priority.compareTo(a.priority);
      }
      return a.order.compareTo(b.order);
    });
  }

  void _toggleTaskCompletion(Task task) {
    context.read<TaskController>().toggleTaskCompletion(task);
  }

  void _deleteTask(BuildContext context, int id) {
    context.read<TaskController>().deleteTask(id);
  }

  void _addTask() {
    _openTaskDetails(null);
  }

  void _openTaskDetails(Task? task) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return TaskDetailsSheet(
          task: task,
          isNewTask: task == null,
        );
      },
    ).then((_) {
      setState(() {
        _sortTasks(context.read<TaskController>().tasks,
            context.read<TaskController>());
      });
    });
  }

  void _toggleSection(int priority) {
    setState(() {
      _expandedSections[priority] = !_expandedSections[priority]!;
    });
  }

  void _clearCompletedTasks() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text('Clear Completed Tasks?'),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.of(context).pop();
              context.read<TaskController>().clearCompletedTasks();
            },
            child: Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskController>(
      builder: (context, taskController, child) {
        _sortTasks(taskController.tasks, taskController);
        final incompleteTasks = _sortedTasks
            .where((task) =>
                !task.isCompleted &&
                !taskController.isTaskPendingCompletion(task.taskId!))
            .length;
        final hasCompletedTasks = _sortedTasks.any((task) => task.isCompleted);

        return Stack(
          children: [
            CupertinoPageScaffold(
              backgroundColor: CupertinoColors.black,
              navigationBar: CupertinoNavigationBar(
                backgroundColor: CupertinoColors.black,
                border: null,
                padding: EdgeInsetsDirectional.fromSTEB(16, 10, 16, 10),
                leading: Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: hasCompletedTasks ? _clearCompletedTasks : null,
                    child: Icon(
                      CupertinoIcons.clear_circled,
                      color: hasCompletedTasks
                          ? CupertinoColors.white
                          : CupertinoColors.systemGrey,
                      size: 28,
                    ),
                  ),
                ),
                middle: Text(
                  incompleteTasks == 0
                      ? 'No tasks left'
                      : '$incompleteTasks task${incompleteTasks == 1 ? '' : 's'} left',
                  style: TextStyle(
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              child: SafeArea(
                child: TaskList(
                  tasks: _sortedTasks,
                  expandedSections: _expandedSections,
                  onToggleSection: _toggleSection,
                  onTaskToggle: _toggleTaskCompletion,
                  onTaskDelete: _deleteTask,
                  onTaskTap: _openTaskDetails,
                  onTaskReorder: (priority, task, newIndex) {
                    context
                        .read<TaskController>()
                        .reorderTasks(priority, task, newIndex);
                  },
                ),
              ),
            ),
            MinimalFloatingActionButton(
              onPressed: _addTask,
              icon: CupertinoIcons.plus,
            ),
            if (_showTutorial)
              FadeTransition(
                opacity: _tutorialFadeAnimation,
                child: TasksTutorial.build(context, _onTutorialComplete),
              ),
          ],
        );
      },
    );
  }
}
