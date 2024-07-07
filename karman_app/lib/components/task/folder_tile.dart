import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:karman_app/components/icon_selection_dialog.dart.dart';
import 'package:karman_app/models/task/task_folder.dart';

class FolderTile extends StatelessWidget {
  final TaskFolder folder;
  final Function() onTap;
  final Function(BuildContext) onEdit;
  final Function(BuildContext) onDelete;
  final Function(IconData) onIconChanged;

  const FolderTile({
    Key? key,
    required this.folder,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onIconChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Material(
        color: Colors.transparent,
        child: Slidable(
          key: ValueKey(folder.folder_id),
          endActionPane: ActionPane(
            motion: DrawerMotion(),
            children: [
              SlidableAction(
                onPressed: onEdit,
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.blueAccent,
                icon: CupertinoIcons.pen,
                label: 'Edit',
              ),
              SlidableAction(
                onPressed: onDelete,
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.redAccent,
                icon: CupertinoIcons.delete,
                label: 'Delete',
              ),
            ],
          ),
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                color: CupertinoColors.darkBackgroundGray,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[700]!,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      showCupertinoDialog(
                        context: context,
                        builder: (context) => IconSelectionDialog(
                          onIconSelected: onIconChanged,
                        ),
                      );
                    },
                    child: Icon(
                      folder.icon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      folder.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
