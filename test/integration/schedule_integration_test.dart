import 'package:flutter_test/flutter_test.dart';
import 'package:lilt/core/constants/app_constants.dart';
import 'package:lilt/data/models/schedule.dart';

/// 集成测试：完整业务场景覆盖
///
/// 注：由于 Firebase 依赖真实项目配置，这些测试覆盖离线逻辑部分。
/// 实际在线集成测试需要通过 Firebase Emulator 完成。
void main() {
  group('Schedule CRUD 集成测试', () {
    // 测试数据工厂
    Schedule createTestSchedule({
      String id = 'test-1',
      String title = '集成测试日程',
      DateTime? startTime,
      DateTime? endTime,
      String category = '工作',
      String color = '#4A90D9',
      ScheduleStatus status = ScheduleStatus.pending,
    }) {
      final start = startTime ?? DateTime(2026, 8, 12, 10, 0);
      return Schedule(
        id: id,
        userId: 'test-user',
        title: title,
        description: '集成测试描述',
        startTime: start,
        endTime: endTime ?? start.add(const Duration(hours: 1)),
        category: category,
        color: color,
        status: status,
        createdAt: DateTime(2026, 8, 12, 8, 0),
      );
    }

    test('Schedule status flow: pending -> in_progress -> completed', () {
      var schedule = createTestSchedule();

      // pending -> in_progress
      schedule = schedule.copyWith(status: ScheduleStatus.inProgress);
      expect(schedule.status, ScheduleStatus.inProgress);
      expect(schedule.toMap()['status'], 'in_progress');

      // in_progress -> completed
      schedule = schedule.copyWith(status: ScheduleStatus.completed);
      expect(schedule.status, ScheduleStatus.completed);
      expect(schedule.toMap()['status'], 'completed');

      // completed -> pending (cycle)
      schedule = schedule.copyWith(status: ScheduleStatus.pending);
      expect(schedule.status, ScheduleStatus.pending);
      expect(schedule.toMap()['status'], 'pending');
    });

    test('Schedule filtering by status logic', () {
      final schedules = [
        createTestSchedule(id: '1', status: ScheduleStatus.pending),
        createTestSchedule(id: '2', status: ScheduleStatus.inProgress),
        createTestSchedule(id: '3', status: ScheduleStatus.completed),
        createTestSchedule(id: '4', status: ScheduleStatus.pending),
      ];

      final pending =
          schedules.where((s) => s.status == ScheduleStatus.pending).toList();
      expect(pending.length, 2);

      final inProgress =
          schedules.where((s) => s.status == ScheduleStatus.inProgress).toList();
      expect(inProgress.length, 1);

      final completed =
          schedules.where((s) => s.status == ScheduleStatus.completed).toList();
      expect(completed.length, 1);
    });

    test('Schedule filtering by category logic', () {
      final schedules = [
        createTestSchedule(id: '1', category: '工作'),
        createTestSchedule(id: '2', category: '个人'),
        createTestSchedule(id: '3', category: '工作'),
        createTestSchedule(id: '4', category: '学习'),
      ];

      final work = schedules.where((s) => s.category == '工作').toList();
      expect(work.length, 2);

      final personal = schedules.where((s) => s.category == '个人').toList();
      expect(personal.length, 1);
    });

    test('Schedule sorting by startTime', () {
      final schedules = [
        createTestSchedule(
          id: '3',
          startTime: DateTime(2026, 8, 12, 14, 0),
        ),
        createTestSchedule(
          id: '1',
          startTime: DateTime(2026, 8, 12, 9, 0),
        ),
        createTestSchedule(
          id: '2',
          startTime: DateTime(2026, 8, 12, 11, 0),
        ),
      ];

      schedules.sort((a, b) => a.startTime.compareTo(b.startTime));
      expect(schedules[0].id, '1');
      expect(schedules[1].id, '2');
      expect(schedules[2].id, '3');
    });

    test('Schedule grouping by date', () {
      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));
      final later = today.add(const Duration(days: 3));

      final schedules = [
        createTestSchedule(id: 'today', startTime: today),
        createTestSchedule(id: 'tomorrow', startTime: tomorrow),
        createTestSchedule(id: 'later', startTime: later),
      ];

      final grouped = <String, List<Schedule>>{};
      for (final s in schedules) {
        grouped.putIfAbsent(s.dateGroupLabel, () => []).add(s);
      }

      expect(grouped['今天']?.length, 1);
      expect(grouped['今天']?.first.id, 'today');
      expect(grouped['明天']?.length, 1);
      expect(grouped['明天']?.first.id, 'tomorrow');
      expect(grouped['之后']?.length, 1);
      expect(grouped['之后']?.first.id, 'later');
    });

    test('Schedule search by keyword', () {
      final schedules = [
        createTestSchedule(id: '1', title: '项目评审会议'),
        createTestSchedule(id: '2', title: '健身训练'),
        createTestSchedule(id: '3', title: '英语学习'),
        createTestSchedule(id: '4', title: '项目复盘'),
      ];

      // Search by title
      final projectResults = schedules
          .where((s) => s.title.contains('项目'))
          .toList();
      expect(projectResults.length, 2);

      final fitnessResults = schedules
          .where((s) => s.title.contains('健身'))
          .toList();
      expect(fitnessResults.length, 1);

      final noResults = schedules
          .where((s) => s.title.contains('不存在'))
          .toList();
      expect(noResults.length, 0);
    });

    test('Complete schedule data round-trip via toMap', () {
      final schedule = createTestSchedule(
        title: 'Round-trip test',
        category: '学习',
        color: '#FF6B6B',
        status: ScheduleStatus.inProgress,
      );

      final map = schedule.toMap();
      expect(map['title'], 'Round-trip test');
      expect(map['userId'], 'test-user');
      expect(map['category'], '学习');
      expect(map['color'], '#FF6B6B');
      expect(map['status'], 'in_progress');
      expect(map['startTime'], isA<DateTime>());
      expect(map['endTime'], isA<DateTime>());
      expect(map['createdAt'], isA<DateTime>());
      expect(map['description'], '集成测试描述');
    });

    test('Statistics calculation: total, completed, completion rate', () {
      final schedules = [
        createTestSchedule(id: '1', status: ScheduleStatus.pending),
        createTestSchedule(id: '2', status: ScheduleStatus.inProgress),
        createTestSchedule(id: '3', status: ScheduleStatus.completed),
        createTestSchedule(id: '4', status: ScheduleStatus.completed),
        createTestSchedule(id: '5', status: ScheduleStatus.pending),
      ];

      final total = schedules.length;
      final completed = schedules
          .where((s) => s.status == ScheduleStatus.completed)
          .length;
      final completionRate = completed / total;

      expect(total, 5);
      expect(completed, 2);
      expect(completionRate, 0.4);
    });

    test('Category distribution calculation', () {
      final schedules = [
        createTestSchedule(id: '1', category: '工作'),
        createTestSchedule(id: '2', category: '工作'),
        createTestSchedule(id: '3', category: '个人'),
        createTestSchedule(id: '4', category: '学习'),
        createTestSchedule(id: '5', category: '工作'),
      ];

      final Map<String, int> distribution = {};
      for (final s in schedules) {
        distribution[s.category] = (distribution[s.category] ?? 0) + 1;
      }

      expect(distribution['工作'], 3);
      expect(distribution['个人'], 1);
      expect(distribution['学习'], 1);
    });

    test('Offline data persistence logic: data available without network', () {
      // 验证离线场景下数据结构仍可用
      final schedule = createTestSchedule();

      // 无需网络即可创建的日程对象
      expect(schedule.title, '集成测试日程');
      expect(schedule.isToday, isTrue);

      // 修改操作无需网络（仅在本地内存中）
      final updated = schedule.copyWith(title: '离线编辑');
      expect(updated.title, '离线编辑');

      // toMap 无需网络
      final map = updated.toMap();
      expect(map['title'], '离线编辑');
    });

    test('AppConstants: default categories and colors match', () {
      expect(AppConstants.defaultCategories.length, 6);
      expect(AppConstants.categoryColors.length, 6);

      for (var i = 0; i < AppConstants.defaultCategories.length; i++) {
        final color = AppConstants.colorForCategory(
          AppConstants.defaultCategories[i],
        );
        expect(color, isNotEmpty);
      }
    });
  });
}
