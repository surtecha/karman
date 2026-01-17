class Todo {
  final int? id;
  final String name;
  final String? description;
  final DateTime? reminder;
  final bool completed;
  final bool pendingCompletion;
  final int sortOrder;
  final bool isDeleted;
  final bool isRepeating;
  final Set<int> repeatDays;

  Todo({
    this.id,
    required this.name,
    this.description,
    this.reminder,
    this.completed = false,
    this.pendingCompletion = false,
    this.sortOrder = 0,
    this.isDeleted = false,
    this.isRepeating = false,
    this.repeatDays = const {},
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
      'is_repeating': isRepeating ? 1 : 0,
      'repeat_days': repeatDays.isEmpty ? null : repeatDays.join(','),
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
      isRepeating: map['is_repeating'] == 1,
      repeatDays: map['repeat_days'] != null
          ? (map['repeat_days'] as String).split(',').map(int.parse).toSet()
          : {},
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
    bool? isRepeating,
    Set<int>? repeatDays,
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
      isRepeating: isRepeating ?? this.isRepeating,
      repeatDays: repeatDays ?? this.repeatDays,
    );
  }

  bool get isVisuallyCompleted => completed || pendingCompletion;
}
