enum ScheduleStatus {
  pending,
  inProgress,
  completed;

  String get label {
    switch (this) {
      case ScheduleStatus.pending:
        return '待办';
      case ScheduleStatus.inProgress:
        return '进行中';
      case ScheduleStatus.completed:
        return '已完成';
    }
  }

  static ScheduleStatus fromString(String value) {
    switch (value) {
      case 'in_progress':
        return ScheduleStatus.inProgress;
      case 'completed':
        return ScheduleStatus.completed;
      default:
        return ScheduleStatus.pending;
    }
  }

  String get apiValue {
    switch (this) {
      case ScheduleStatus.pending:
        return 'pending';
      case ScheduleStatus.inProgress:
        return 'in_progress';
      case ScheduleStatus.completed:
        return 'completed';
    }
  }
}

class Schedule {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String category;
  final String color;
  final ScheduleStatus status;
  final DateTime createdAt;

  const Schedule({
    required this.id,
    required this.userId,
    required this.title,
    this.description = '',
    required this.startTime,
    required this.endTime,
    required this.category,
    required this.color,
    this.status = ScheduleStatus.pending,
    required this.createdAt,
  });

  Schedule copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? category,
    String? color,
    ScheduleStatus? status,
    DateTime? createdAt,
  }) {
    return Schedule(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      category: category ?? this.category,
      color: color ?? this.color,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'startTime': startTime,
      'endTime': endTime,
      'category': category,
      'color': color,
      'status': status.apiValue,
      'createdAt': createdAt,
    };
  }

  factory Schedule.fromFirestore(String id, Map<String, dynamic> data) {
    return Schedule(
      id: id,
      userId: data['userId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      startTime: (data['startTime'] as dynamic).toDate(),
      endTime: (data['endTime'] as dynamic).toDate(),
      category: data['category'] as String? ?? '',
      color: (data['color'] as String?)?.isNotEmpty == true
          ? data['color'] as String
          : '#4A90D9',
      status: ScheduleStatus.fromString(data['status'] as String? ?? 'pending'),
      createdAt: (data['createdAt'] as dynamic).toDate(),
    );
  }

  bool get isToday {
    final now = DateTime.now();
    return startTime.year == now.year &&
        startTime.month == now.month &&
        startTime.day == now.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return startTime.year == tomorrow.year &&
        startTime.month == tomorrow.month &&
        startTime.day == tomorrow.day;
  }

  String get dateGroupLabel {
    if (isToday) return '今天';
    if (isTomorrow) return '明天';
    return '之后';
  }

  Duration? timeUntilStart() {
    final now = DateTime.now();
    if (startTime.isAfter(now)) {
      return startTime.difference(now);
    }
    return null;
  }
}
