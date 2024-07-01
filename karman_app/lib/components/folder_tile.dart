import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class FolderTile extends StatelessWidget {
  final String folderName;
  final Function(BuildContext)? onEdit;
  final Function(BuildContext)? onDelete;
  final Function()? onTap;

  FolderTile({
    super.key,
    required this.folderName,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Material(
        color: Colors.transparent,
        child: Slidable(
          key: ValueKey(folderName),
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
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  folderName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
