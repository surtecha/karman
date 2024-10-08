class Task {
  final int? taskId;
  final String name;
  final String? note;
  final int priority;
  final DateTime? dueDate;
  final DateTime? reminder;
  final bool isCompleted;
  final int order;

  Task({
    this.taskId,
    required this.name,
    this.note,
    required this.priority,
    this.dueDate,
    this.reminder,
    this.isCompleted = false,
    required this.order,
  });

  Map<String, dynamic> toMap() {
    return {
      'task_id': taskId,
      'name': name,
      'note': note,
      'priority': priority,
      'due_date': dueDate?.toIso8601String(),
      'reminder': reminder?.toIso8601String(),
      'is_completed': isCompleted ? 1 : 0,
      'order': order,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      taskId: map['task_id'],
      name: map['name'],
      note: map['note'],
      priority: map['priority'],
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date']) : null,
      reminder: map['reminder'] != null ? DateTime.parse(map['reminder']) : null,
      isCompleted: map['is_completed'] == 1,
      order: map['order'],
    );
  }

  Task copyWith({
    int? taskId,
    String? name,
    String? note,
    int? priority,
    DateTime? dueDate,
    DateTime? reminder,
    bool? isCompleted,
    int? order,
  }) {
    return Task(
      taskId: taskId ?? this.taskId,
      name: name ?? this.name,
      note: note ?? this.note,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      reminder: reminder ?? this.reminder,
      isCompleted: isCompleted ?? this.isCompleted,
      order: order ?? this.order,
    );
  }
}