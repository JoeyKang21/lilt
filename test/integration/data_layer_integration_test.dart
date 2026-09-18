import 'package:flutter_test/flutter_test.dart';
import 'package:lilt/data/models/schedule.dart';
import 'package:lilt/core/constants/app_constants.dart';
import 'package:lilt/core/validators/validators.dart';

/// 数据层集成测试
/// 测试模型、校验、常量之间的协作关系
void main() {
  group('Data Layer Integration', () {
    final now = DateTime(2026, 8, 12, 10, 0);
    final validSchedule = Schedule(
      id: 'integ-test-1',
      userId: 'user-1',
      title: '集成测试日程',
      description: '集成测试描述',
      startTime: now,
      endTime: now.add(const Duration(hours: 2)),
      category: '工作',
      color: '#4A90D9',
      status: ScheduleStatus.pending,
      createdAt: now.subtract(const Duration(hours: 1)),
    );

    test('Schedule toMap -> ScheduleData validation passes', () {
      final data = ScheduleData.fromSchedule(validSchedule);
      final result = ScheduleValidator.validate(data);
      expect(result.isValid, isTrue);
    });

    test('ScheduleData validates correctly with all categories', () {
      for (final category in AppConstants.defaultCategories) {
        final data = ScheduleData(
          title: '测试 $category',
          description: '描述',
          startTime: now,
          endTime: now.add(const Duration(hours: 1)),
          category: category,
          color: AppConstants.colorForCategory(category),
          status: 'pending',
        );
        expect(
          ScheduleValidator.validate(data).isValid,
          isTrue,
          reason: 'Category $category should validate',
        );
      }
    });

    test('Schedule status flow: pending -> in_progress -> completed', () {
      var schedule = validSchedule;
      expect(schedule.status, ScheduleStatus.pending);

      schedule = schedule.copyWith(status: ScheduleStatus.inProgress);
      expect(schedule.status, ScheduleStatus.inProgress);

      final data = ScheduleData.fromSchedule(schedule);
      expect(data.status, 'in_progress');

      schedule = schedule.copyWith(status: ScheduleStatus.completed);
      expect(schedule.status, ScheduleStatus.completed);

      final completedData = ScheduleData.fromSchedule(schedule);
      expect(completedData.status, 'completed');
    });

    test('Date grouping logic works correctly in sequence', () {
      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));
      final later = today.add(const Duration(days: 5));

      final todaySchedule = Schedule(
        id: 't1',
        userId: 'u1',
        title: 'T',
        startTime: today,
        endTime: today.add(const Duration(hours: 1)),
        category: '工作',
        color: '#4A90D9',
        createdAt: today,
      );
      final tomorrowSchedule = Schedule(
        id: 't2',
        userId: 'u1',
        title: 'T',
        startTime: tomorrow,
        endTime: tomorrow.add(const Duration(hours: 1)),
        category: '工作',
        color: '#4A90D9',
        createdAt: tomorrow,
      );
      final laterSchedule = Schedule(
        id: 't3',
        userId: 'u1',
        title: 'T',
        startTime: later,
        endTime: later.add(const Duration(hours: 1)),
        category: '工作',
        color: '#4A90D9',
        createdAt: later,
      );

      expect(todaySchedule.dateGroupLabel, '今天');
      expect(tomorrowSchedule.dateGroupLabel, '明天');
      expect(laterSchedule.dateGroupLabel, '之后');

      final grouped = <String, List<Schedule>>{};
      for (final s in [todaySchedule, tomorrowSchedule, laterSchedule]) {
        grouped.putIfAbsent(s.dateGroupLabel, () => []).add(s);
      }

      expect(grouped.length, 3);
      expect(grouped['今天']!.length, 1);
      expect(grouped['明天']!.length, 1);
      expect(grouped['之后']!.length, 1);
    });

    test('copyWith + validation workflow', () {
      var schedule = validSchedule;
      schedule = schedule.copyWith(
        title: 'Updated',
        description: 'Updated description',
      );

      final data = ScheduleData.fromSchedule(schedule);
      final result = ScheduleValidator.validate(data);
      expect(result.isValid, isTrue);
      expect(data.title, 'Updated');
    });

    test('Color mapping consistency: category -> color -> validation', () {
      for (final category in AppConstants.defaultCategories) {
        final mappedColor = AppConstants.colorForCategory(category);
        final colorValid = ScheduleValidator.validateColor(mappedColor);
        expect(colorValid.isValid, isTrue,
            reason: 'Mapped color $mappedColor for $category should be valid');

        final categoryValid = ScheduleValidator.validateCategory(category);
        expect(categoryValid.isValid, isTrue);
      }
    });
  });
}
