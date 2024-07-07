class Task {
  final int? taskId; // Changed from id to task_id
  final String name;
  final String? note;
  final int priority;
  final DateTime? dueDate;
  final DateTime? reminder;
  final int folderId;
  final bool isCompleted;

  Task({
    this.taskId, // Changed from id to task_id
    required this.name,
    this.note,
    required this.priority,
    this.dueDate,
    this.reminder,
    required this.folderId,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'task_id': taskId, 
      'name': name,
      'note': note,
      'priority': priority,
      'due_date': dueDate?.toIso8601String(),
      'reminder': reminder?.toIso8601String(),
      'folder_id': folderId,
      'is_completed': isCompleted ? 1 : 0,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      taskId: map['task_id'], 
      name: map['name'],
      note: map['note'],
      priority: map['priority'],
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date']) : null,
      reminder:
          map['reminder'] != null ? DateTime.parse(map['reminder']) : null,
      folderId: map['folder_id'],
      isCompleted: map['is_completed'] == 1,
    );
  }

  // Update the copyWith method as well
  Task copyWith({
    int? taskId,
    String? name,
    String? note,
    int? priority,
    DateTime? dueDate,
    DateTime? reminder,
    int? folderId,
    bool? isCompleted,
  }) {
    return Task(
      taskId: taskId ?? this.taskId, 
      name: name ?? this.name,
      note: note ?? this.note,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      reminder: reminder ?? this.reminder,
      folderId: folderId ?? this.folderId,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
