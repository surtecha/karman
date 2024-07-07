import 'package:flutter/cupertino.dart';

class TaskFolder {
  final int? folder_id;
  final String name;
  final IconData icon;

  TaskFolder({
    this.folder_id,
    required this.name,
    this.icon = CupertinoIcons.folder_fill,
  });

  Map<String, dynamic> toMap() {
    return {
      'folder_id': folder_id,
      'name': name,
      'icon': icon.codePoint,
    };
  }

  factory TaskFolder.fromMap(Map<String, dynamic> map) {
    return TaskFolder(
      folder_id: map['folder_id'],
      name: map['name'],
      icon: IconData(map['icon'],
          fontFamily: CupertinoIcons.folder_fill.fontFamily),
    );
  }
}
