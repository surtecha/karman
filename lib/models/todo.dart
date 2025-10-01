class Todo {
  final int? id;
  final String name;
  final String? description;
  final DateTime? reminder;
  final bool completed;
  final bool pendingCompletion;
  final int sortOrder;
  final bool isDeleted;

  Todo({
    this.id,
    required this.name,
    this.description,
    this.reminder,
    this.completed = false,
    this.pendingCompletion = false,
    this.sortOrder = 0,
    this.isDeleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'reminder': reminder?.millisecondsSinceEpoch,
      'completed': completed ? 1 : 0,
      'sort_order': sortOrder,
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      reminder:
          map['reminder'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['reminder'])
              : null,
      completed: map['completed'] == 1,
      sortOrder: map['sort_order'] ?? 0,
      isDeleted: map['is_deleted'] == 1,
    );
  }

  Todo copyWith({
    int? id,
    String? name,
    String? description,
    DateTime? reminder,
    bool? completed,
    bool? pendingCompletion,
    int? sortOrder,
    bool? isDeleted,
  }) {
    return Todo(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      reminder: reminder ?? this.reminder,
      completed: completed ?? this.completed,
      pendingCompletion: pendingCompletion ?? this.pendingCompletion,
      sortOrder: sortOrder ?? this.sortOrder,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  bool get isVisuallyCompleted => completed || pendingCompletion;
}
