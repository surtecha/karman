import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:karman_app/components/dialog_window.dart';
import 'package:karman_app/components/folder_tile.dart';

class FolderDrawer extends StatefulWidget {
  final List<String> folders;
  final Function(String) onFolderSelected;
  final TextEditingController controller;
  final VoidCallback onCreateFolder;
  final Function(BuildContext, int) onEditFolder;
  final Function(BuildContext, int) onDeleteFolder;

  const FolderDrawer({
    super.key,
    required this.folders,
    required this.onFolderSelected,
    required this.controller,
    required this.onCreateFolder,
    required this.onEditFolder,
    required this.onDeleteFolder,
  });

  @override
  _FolderDrawerState createState() => _FolderDrawerState();
}

class _FolderDrawerState extends State<FolderDrawer> {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.2,
      maxChildSize: 0.9,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: CupertinoColors.darkBackgroundGray,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(20),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        'Folders',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          showCupertinoDialog(
                            context: context,
                            builder: (context) {
                              return KarmanDialogWindow(
                                controller: widget.controller,
                                onSave: () {
                                  setState(() {
                                    widget.onCreateFolder();
                                  });
                                  Navigator.of(context).pop();
                                },
                                onCancel: () {
                                  widget.controller.clear();
                                  Navigator.of(context).pop();
                                },
                              );
                            },
                          );
                        },
                        child: Icon(
                          CupertinoIcons.add_circled,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: List.generate(widget.folders.length, (index) {
                      return FolderTile(
                        folderName: widget.folders[index],
                        onTap: () {
                          widget.onFolderSelected(widget.folders[index]);
                          Navigator.of(context).pop();
                        },
                        onEdit: (context) {
                          widget.onEditFolder(context, index);
                          setState(() {}); // Update state after editing
                        },
                        onDelete: (context) {
                          widget.onDeleteFolder(context, index);
                          setState(() {}); // Update state after deleting
                        },
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
