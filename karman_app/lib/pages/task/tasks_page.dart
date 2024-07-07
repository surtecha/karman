import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:karman_app/components/dialog_window.dart';
import 'package:karman_app/components/task/completed_task_header.dart';
import 'package:karman_app/controllers/task/task_controller.dart';
import 'package:karman_app/models/task/task.dart';
import 'package:karman_app/models/task/task_folder.dart';
import 'package:karman_app/pages/task/task_details_sheet.dart';
import 'package:karman_app/components/task/task_tile.dart';
import 'package:karman_app/components/task/folder_drawer.dart';
import 'package:provider/provider.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({Key? key}) : super(key: key);

  @override
  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  int currentFolderId = 1; // Assuming 1 is the default folder ID
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<Task> _sortedTasks = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskController>().loadTasks();
      context.read<TaskController>().loadFolders();
    });
  }

  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _folderController = TextEditingController();

  void _addFolder() {
    final newFolder = TaskFolder(name: _folderController.text);
    context.read<TaskController>().addFolder(newFolder).then((folder) {
      if (folder != null && folder.folder_id != null) {
        setState(() {
          currentFolderId = folder.folder_id!;
        });
      }
    });
    _folderController.clear();
  }

  void _sortTasks(List<Task> tasks) {
    tasks.sort((a, b) {
      if (a.isCompleted == b.isCompleted) {
        return 0;
      }
      return a.isCompleted ? 1 : -1;
    });
  }

  void _toggleTaskCompletion(Task task) {
    final taskIndex = _sortedTasks.indexWhere((t) => t.taskId == task.taskId);
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);

    context.read<TaskController>().updateTask(updatedTask);

    setState(() {
      _sortedTasks[taskIndex] = updatedTask;
    });

    _listKey.currentState!.removeItem(
      taskIndex,
      (context, animation) => _buildAnimatedItem(updatedTask, animation),
      duration: Duration(milliseconds: 250),
    );

    Future.delayed(Duration(milliseconds: 250), () {
      setState(() {
        _sortTasks(_sortedTasks);
      });

      final newIndex =
          _sortedTasks.indexWhere((t) => t.taskId == updatedTask.taskId);
      _listKey.currentState!
          .insertItem(newIndex, duration: Duration(milliseconds: 250));
    });
  }

  void _editTask(BuildContext context, Task task) {
    _taskController.text = task.name;
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return KarmanDialogWindow(
          controller: _taskController,
          onSave: () {
            final updatedTask = task.copyWith(name: _taskController.text);
            context.read<TaskController>().updateTask(updatedTask);
            _taskController.clear();
            Navigator.of(context).pop();
          },
          onCancel: () {
            _taskController.clear();
            Navigator.of(context).pop();
          },
          initialText: task.name,
        );
      },
    );
  }

  void _deleteTask(BuildContext context, int id) {
    final index = _sortedTasks.indexWhere((task) => task.taskId == id);
    if (index != -1) {
      final removedTask = _sortedTasks.removeAt(index);
      context.read<TaskController>().deleteTask(id);

      _listKey.currentState!.removeItem(
        index,
        (context, animation) => _buildAnimatedItem(removedTask, animation),
        duration: Duration(milliseconds: 250),
      );
    }
  }

  void _addTask() {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return KarmanDialogWindow(
          controller: _taskController,
          onSave: () {
            final newTask = Task(
              name: _taskController.text,
              priority: 1,
              folderId: currentFolderId,
            );
            context.read<TaskController>().addTask(newTask).then((task) {
              if (task != null) {
                setState(() {
                  _sortedTasks.insert(0, task);
                });
                if (_listKey.currentState != null) {
                  _listKey.currentState!
                      .insertItem(0, duration: Duration(milliseconds: 250));
                }
              }
            });
            _taskController.clear();
            Navigator.of(context).pop();
          },
          onCancel: () {
            _taskController.clear();
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _openDrawer() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return FolderDrawer(
          onFolderSelected: (folder) {
            setState(() {
              currentFolderId = folder.folder_id!;
            });
          },
          controller: _folderController,
          onCreateFolder: _addFolder,
        );
      },
    );
  }

  void _openTaskDetails(Task task) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return TaskDetailsSheet(
          task: task,
        );
      },
    );
  }

  String getAppbarTitle(List<TaskFolder> folders) {
    if (folders.isEmpty) {
      return "¯\\_(ツ)_/¯";
    } else {
      final currentFolder = folders.firstWhere(
        (folder) => folder.folder_id == currentFolderId,
        orElse: () => TaskFolder(folder_id: -1, name: 'Unknown Folder'),
      );
      return currentFolder.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskController>(
      builder: (context, taskController, child) {
        final folders = taskController.folders;
        final tasks = taskController.getTasksForFolder(currentFolderId);

        if (folders.isEmpty) {
          return CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              backgroundColor: Colors.black,
              middle: Text(
                "Folder-less and fancy-free!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _openDrawer,
                child: Icon(
                  CupertinoIcons.square_stack,
                  color: CupertinoColors.white,
                  size: 20,
                ),
              ),
            ),
            child: SafeArea(
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Your tasks are feeling homeless!",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 30),
                    Text(
                      "Click the icon in the top left to create a new folder.",
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            backgroundColor: Colors.black,
            middle: Text(
              getAppbarTitle(folders),
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _openDrawer,
              child: Icon(
                CupertinoIcons.square_stack,
                color: CupertinoColors.white,
                size: 20,
              ),
            ),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _addTask,
              child: Icon(
                CupertinoIcons.plus,
                color: CupertinoColors.white,
                size: 20,
              ),
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                SizedBox(height: 8),
                CompletedTasksHeader(currentFolderId: currentFolderId),
                Expanded(
                  child: _buildTasksList(folders, tasks),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTasksList(List<TaskFolder> folders, List<Task> tasks) {
    if (tasks.isEmpty) {
      return Center(
        child: Text(
          'This space craves your brilliant ideas. Add one!',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      );
    } else {
      if (_sortedTasks.isEmpty || !listEquals(_sortedTasks, tasks)) {
        _sortedTasks = List.from(tasks);
        _sortTasks(_sortedTasks);
      }

      return Builder(
        builder: (context) {
          return AnimatedList(
            key: _listKey,
            initialItemCount: _sortedTasks.length,
            itemBuilder: (context, index, animation) {
              return _buildAnimatedItem(_sortedTasks[index], animation);
            },
          );
        },
      );
    }
  }

  Widget _buildAnimatedItem(Task task, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: GestureDetector(
        onTap: () => _openTaskDetails(task),
        child: TaskTile(
          key: ValueKey(task.taskId),
          task: task,
          onChanged: (value) => _toggleTaskCompletion(task),
          onEdit: (context) => _editTask(context, task),
          onDelete: (context) => _deleteTask(context, task.taskId!),
        ),
      ),
    );
  }
}
