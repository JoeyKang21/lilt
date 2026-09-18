import 'package:flutter/material.dart';
import '../../data/models/schedule.dart';

/// 通用日程状态标签组件
class StatusChip extends StatelessWidget {
  final ScheduleStatus status;
  final double fontSize;

  const StatusChip({
    super.key,
    required this.status,
    this.fontSize = 11,
  });

  Color get _color {
    switch (status) {
      case ScheduleStatus.pending:
        return Colors.orange;
      case ScheduleStatus.inProgress:
        return Colors.blue;
      case ScheduleStatus.completed:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color),
      ),
      child: Text(
        status.label,
        style: TextStyle(fontSize: fontSize, color: _color),
      ),
    );
  }
}
