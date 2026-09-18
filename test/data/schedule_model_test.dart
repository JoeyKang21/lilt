import 'package:flutter_test/flutter_test.dart';
import 'package:lilt/data/models/schedule.dart';

void main() {
  group('ScheduleStatus', () {
    test('pending label is correct', () {
      expect(ScheduleStatus.pending.label, '待办');
    });

    test('inProgress label is correct', () {
      expect(ScheduleStatus.inProgress.label, '进行中');
    });

    test('completed label is correct', () {
      expect(ScheduleStatus.completed.label, '已完成');
    });

    test('fromString parses pending correctly', () {
      expect(ScheduleStatus.fromString('pending'), ScheduleStatus.pending);
    });

    test('fromString parses in_progress correctly', () {
      expect(
        ScheduleStatus.fromString('in_progress'),
        ScheduleStatus.inProgress,
      );
    });

    test('fromString parses completed correctly', () {
      expect(ScheduleStatus.fromString('completed'), ScheduleStatus.completed);
    });

    test('fromString defaults to pending for unknown value', () {
      expect(ScheduleStatus.fromString('unknown'), ScheduleStatus.pending);
    });

    test('fromString defaults to pending for empty value', () {
      expect(ScheduleStatus.fromString(''), ScheduleStatus.pending);
    });

    test('apiValue returns correct values', () {
      expect(ScheduleStatus.pending.apiValue, 'pending');
      expect(ScheduleStatus.inProgress.apiValue, 'in_progress');
      expect(ScheduleStatus.completed.apiValue, 'completed');
    });
  });

  group('Schedule model', () {
    final testSchedule = Schedule(
      id: 'test-id',
      userId: 'user-1',
      title: '测试日程',
      description: '测试描述',
      startTime: DateTime(2026, 8, 12, 10, 0),
      endTime: DateTime(2026, 8, 12, 12, 0),
      category: '工作',
      color: '#4A90D9',
      status: ScheduleStatus.pending,
      createdAt: DateTime(2026, 8, 12, 8, 0),
    );

    test('constructor creates valid Schedule', () {
      expect(testSchedule.id, 'test-id');
      expect(testSchedule.userId, 'user-1');
      expect(testSchedule.title, '测试日程');
      expect(testSchedule.description, '测试描述');
      expect(testSchedule.category, '工作');
      expect(testSchedule.color, '#4A90D9');
      expect(testSchedule.status, ScheduleStatus.pending);
    });

    test('default values are correct', () {
      final schedule = Schedule(
        id: '1',
        userId: 'u1',
        title: 'Test',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 1)),
        category: '工作',
        color: '#4A90D9',
        createdAt: DateTime.now(),
      );
      expect(schedule.description, '');
      expect(schedule.status, ScheduleStatus.pending);
    });

    test('isToday returns true for today', () {
      final today = DateTime.now();
      final schedule = Schedule(
        id: '1',
        userId: 'u1',
        title: 'Today',
        startTime: today,
        endTime: today.add(const Duration(hours: 1)),
        category: '工作',
        color: '#4A90D9',
        createdAt: today,
      );
      expect(schedule.isToday, isTrue);
    });

    test('isToday returns false for a different day', () {
      final schedule = Schedule(
        id: '1',
        userId: 'u1',
        title: 'Past',
        startTime: DateTime(2020, 1, 1),
        endTime: DateTime(2020, 1, 1, 1),
        category: '工作',
        color: '#4A90D9',
        createdAt: DateTime(2020, 1, 1),
      );
      expect(schedule.isToday, isFalse);
    });

    test('isTomorrow returns true for tomorrow', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final schedule = Schedule(
        id: '1',
        userId: 'u1',
        title: 'Tomorrow',
        startTime: tomorrow,
        endTime: tomorrow.add(const Duration(hours: 1)),
        category: '工作',
        color: '#4A90D9',
        createdAt: tomorrow,
      );
      expect(schedule.isTomorrow, isTrue);
    });

    test('isTomorrow returns false for today', () {
      final schedule = Schedule(
        id: '1',
        userId: 'u1',
        title: 'Today',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 1)),
        category: '工作',
        color: '#4A90D9',
        createdAt: DateTime.now(),
      );
      expect(schedule.isTomorrow, isFalse);
    });

    test('dateGroupLabel returns 今天 for today', () {
      final schedule = Schedule(
        id: '1',
        userId: 'u1',
        title: 'Today',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 1)),
        category: '工作',
        color: '#4A90D9',
        createdAt: DateTime.now(),
      );
      expect(schedule.dateGroupLabel, '今天');
    });

    test('dateGroupLabel returns 明天 for tomorrow', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final schedule = Schedule(
        id: '1',
        userId: 'u1',
        title: 'Tomorrow',
        startTime: tomorrow,
        endTime: tomorrow.add(const Duration(hours: 1)),
        category: '工作',
        color: '#4A90D9',
        createdAt: tomorrow,
      );
      expect(schedule.dateGroupLabel, '明天');
    });

    test('dateGroupLabel returns 之后 for future dates', () {
      final later = DateTime.now().add(const Duration(days: 3));
      final schedule = Schedule(
        id: '1',
        userId: 'u1',
        title: 'Later',
        startTime: later,
        endTime: later.add(const Duration(hours: 1)),
        category: '工作',
        color: '#4A90D9',
        createdAt: later,
      );
      expect(schedule.dateGroupLabel, '之后');
    });

    test('timeUntilStart returns positive duration for future time', () {
      final futureTime = DateTime.now().add(const Duration(hours: 3));
      final schedule = Schedule(
        id: '1',
        userId: 'u1',
        title: 'Future',
        startTime: futureTime,
        endTime: futureTime.add(const Duration(hours: 1)),
        category: '工作',
        color: '#4A90D9',
        createdAt: DateTime.now(),
      );
      final remaining = schedule.timeUntilStart();
      expect(remaining, isNotNull);
      expect(remaining!.inHours, greaterThanOrEqualTo(2));
      expect(remaining.inHours, lessThanOrEqualTo(3));
    });

    test('timeUntilStart returns null for past time', () {
      final pastTime = DateTime.now().subtract(const Duration(hours: 1));
      final schedule = Schedule(
        id: '1',
        userId: 'u1',
        title: 'Past',
        startTime: pastTime,
        endTime: DateTime.now(),
        category: '工作',
        color: '#4A90D9',
        createdAt: pastTime,
      );
      expect(schedule.timeUntilStart(), isNull);
    });

    test('copyWith preserves unchanged values', () {
      final updated = testSchedule.copyWith(title: '修改后的标题');
      expect(updated.title, '修改后的标题');
      expect(updated.id, 'test-id');
      expect(updated.userId, 'user-1');
      expect(updated.category, '工作');
      expect(updated.status, ScheduleStatus.pending);
    });

    test('copyWith changes all provided values', () {
      final updated = testSchedule.copyWith(
        title: '新标题',
        status: ScheduleStatus.completed,
        category: '个人',
        color: '#50C878',
      );
      expect(updated.title, '新标题');
      expect(updated.status, ScheduleStatus.completed);
      expect(updated.category, '个人');
      expect(updated.color, '#50C878');
    });

    test('toMap produces correct Firestore format', () {
      final map = testSchedule.toMap();
      expect(map['userId'], 'user-1');
      expect(map['title'], '测试日程');
      expect(map['description'], '测试描述');
      expect(map['category'], '工作');
      expect(map['color'], '#4A90D9');
      expect(map['status'], 'pending');
      expect(map['startTime'], isA<DateTime>());
      expect(map['endTime'], isA<DateTime>());
      expect(map['createdAt'], isA<DateTime>());
    });

    test('fromFirestore parses Firestore data correctly', () {
      final now = DateTime(2026, 8, 12, 10, 0);
      final data = <String, dynamic>{
        'userId': 'user-1',
        'title': 'Firestore Test',
        'description': 'Description text',
        'startTime': _TimestampStub(now),
        'endTime': _TimestampStub(now.add(const Duration(hours: 1))),
        'category': '学习',
        'color': '#FF6B6B',
        'status': 'in_progress',
        'createdAt': _TimestampStub(now.subtract(const Duration(hours: 1))),
      };

      final schedule = Schedule.fromFirestore('doc-id', data);
      expect(schedule.id, 'doc-id');
      expect(schedule.title, 'Firestore Test');
      expect(schedule.status, ScheduleStatus.inProgress);
      expect(schedule.category, '学习');
      expect(schedule.color, '#FF6B6B');
    });

    test('fromFirestore handles missing optional fields with defaults', () {
      final now = DateTime(2026, 8, 12, 10, 0);
      final data = <String, dynamic>{
        'userId': 'user-1',
        'title': 'Minimal',
        'startTime': _TimestampStub(now),
        'endTime': _TimestampStub(now.add(const Duration(hours: 1))),
        'category': '',
        'color': '',
        'status': null,
        'createdAt': _TimestampStub(now),
      };

      final schedule = Schedule.fromFirestore('doc-id', data);
      expect(schedule.description, '');
      expect(schedule.status, ScheduleStatus.pending);
      expect(schedule.color, '#4A90D9');
    });
  });
}

class _TimestampStub {
  final DateTime _date;
  const _TimestampStub(this._date);
  DateTime toDate() => _date;
}
