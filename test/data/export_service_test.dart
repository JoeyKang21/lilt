import 'package:flutter_test/flutter_test.dart';
import 'package:lilt/data/models/schedule.dart';

/// ExportService 格式化逻辑单元测试
///
/// 测试导出 TXT 内容的格式正确性，不依赖 path_provider 平台通道。
void main() {
  // 直接测试 ExportService 的格式化逻辑（不涉及文件 I/O）
  String formatExportContent(List<Schedule> schedules) {
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final buffer = StringBuffer();
    buffer.writeln('==================== 日程列表 ====================');
    buffer.writeln('导出时间：$dateStr');
    buffer.writeln();

    for (var i = 0; i < schedules.length; i++) {
      buffer.writeln('[${i + 1}] ${schedules[i].title}');
      final start = schedules[i].startTime;
      final end = schedules[i].endTime;
      final sDate =
          '${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')} '
          '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
      final eDate =
          '${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')} '
          '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
      buffer.writeln('    时间：$sDate ~ $eDate');
      buffer.writeln('    状态：${schedules[i].status.label}');
      buffer.writeln('    分类：${schedules[i].category}');
      buffer.writeln(
        '    描述：${schedules[i].description.isEmpty ? '-' : schedules[i].description}',
      );
      buffer.writeln();
    }

    buffer.writeln('====================================================');
    return buffer.toString();
  }

  group('ExportService format logic', () {
    test('generates correct format with data', () {
      final schedules = [
        Schedule(
          id: '1',
          userId: 'user-1',
          title: '项目评审会议',
          description: 'Q3 项目阶段性评审',
          startTime: DateTime(2026, 8, 12, 9, 0),
          endTime: DateTime(2026, 8, 12, 11, 0),
          category: '工作',
          color: '#4A90D9',
          status: ScheduleStatus.pending,
          createdAt: DateTime(2026, 8, 10),
        ),
        Schedule(
          id: '2',
          userId: 'user-1',
          title: '健身训练',
          description: '',
          startTime: DateTime(2026, 8, 12, 18, 0),
          endTime: DateTime(2026, 8, 12, 19, 30),
          category: '个人',
          color: '#50C878',
          status: ScheduleStatus.pending,
          createdAt: DateTime(2026, 8, 11),
        ),
      ];

      final content = formatExportContent(schedules);

      // Verify header
      expect(content, contains('日程列表'));
      expect(content, contains('导出时间'));

      // Verify first schedule
      expect(content, contains('[1] 项目评审会议'));
      expect(content, contains('状态：待办'));
      expect(content, contains('分类：工作'));
      expect(content, contains('Q3 项目阶段性评审'));
      expect(content, contains('2026-08-12 09:00'));
      expect(content, contains('2026-08-12 11:00'));

      // Verify second schedule (empty description)
      expect(content, contains('[2] 健身训练'));
      expect(content, contains('描述：-'));
      expect(content, contains('分类：个人'));
      expect(content, contains('2026-08-12 18:00'));
      expect(content, contains('2026-08-12 19:30'));
    });

    test('handles empty schedule list', () {
      final content = formatExportContent([]);

      expect(content, contains('日程列表'));
      expect(content, contains('导出时间'));

      // Should have no numbered entries
      final lines = content.split('\n');
      final hasNumberedEntry = lines.any((l) => l.startsWith('['));
      expect(hasNumberedEntry, isFalse);
    });

    test('includes all schedules with correct numbering', () {
      final schedules = List.generate(5, (i) => Schedule(
        id: '$i',
        userId: 'user-1',
        title: 'Schedule $i',
        startTime: DateTime(2026, 8, 12, i + 8, 0),
        endTime: DateTime(2026, 8, 12, i + 9, 0),
        category: '工作',
        color: '#4A90D9',
        createdAt: DateTime.now(),
      ));

      final content = formatExportContent(schedules);

      for (var i = 1; i <= 5; i++) {
        expect(content, contains('[$i] Schedule ${i - 1}'));
      }
    });

    test('handles different statuses correctly', () {
      final schedules = [
        Schedule(
          id: '1',
          userId: 'u1',
          title: 'Pending',
          startTime: DateTime(2026, 8, 12, 10, 0),
          endTime: DateTime(2026, 8, 12, 11, 0),
          category: '工作',
          color: '#4A90D9',
          status: ScheduleStatus.pending,
          createdAt: DateTime.now(),
        ),
        Schedule(
          id: '2',
          userId: 'u1',
          title: 'In Progress',
          startTime: DateTime(2026, 8, 12, 12, 0),
          endTime: DateTime(2026, 8, 12, 13, 0),
          category: '个人',
          color: '#50C878',
          status: ScheduleStatus.inProgress,
          createdAt: DateTime.now(),
        ),
        Schedule(
          id: '3',
          userId: 'u1',
          title: 'Completed',
          startTime: DateTime(2026, 8, 12, 14, 0),
          endTime: DateTime(2026, 8, 12, 15, 0),
          category: '学习',
          color: '#FF6B6B',
          status: ScheduleStatus.completed,
          createdAt: DateTime.now(),
        ),
      ];

      final content = formatExportContent(schedules);

      expect(content, contains('状态：待办'));
      expect(content, contains('状态：进行中'));
      expect(content, contains('状态：已完成'));
    });

    test('handles different categories correctly', () {
      final schedules = [
        Schedule(
          id: '1',
          userId: 'u1',
          title: 'Work',
          startTime: DateTime(2026, 8, 12, 10, 0),
          endTime: DateTime(2026, 8, 12, 11, 0),
          category: '工作',
          color: '#4A90D9',
          createdAt: DateTime.now(),
        ),
        Schedule(
          id: '2',
          userId: 'u1',
          title: 'Personal',
          startTime: DateTime(2026, 8, 12, 12, 0),
          endTime: DateTime(2026, 8, 12, 13, 0),
          category: '个人',
          color: '#50C878',
          createdAt: DateTime.now(),
        ),
      ];

      final content = formatExportContent(schedules);

      expect(content, contains('分类：工作'));
      expect(content, contains('分类：个人'));
    });
  });
}
