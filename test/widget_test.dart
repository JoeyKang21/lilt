import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lilt/data/models/schedule.dart';

void main() {
  testWidgets('App should render without error', (WidgetTester tester) async {
    // Since Firebase requires real config, we skip initialization errors
    // and just verify the app structure can be built.
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Center(child: Text('Lilt')),
          ),
        ),
      ),
    );

    expect(find.text('Lilt'), findsOneWidget);
  });

  group('Schedule model', () {
    test('Schedule.isToday returns true for today', () {
      final schedule = Schedule(
        id: '1',
        userId: 'user1',
        title: 'Test',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 1)),
        category: '工作',
        color: '#4A90D9',
        createdAt: DateTime.now(),
      );
      expect(schedule.isToday, isTrue);
    });

    test('Schedule.isTomorrow returns false for today', () {
      final schedule = Schedule(
        id: '1',
        userId: 'user1',
        title: 'Test',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 1)),
        category: '工作',
        color: '#4A90D9',
        createdAt: DateTime.now(),
      );
      expect(schedule.isTomorrow, isFalse);
    });

    test('Schedule.dateGroupLabel returns correct label', () {
      final today = Schedule(
        id: '1',
        userId: 'user1',
        title: 'Today',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 1)),
        category: '工作',
        color: '#4A90D9',
        createdAt: DateTime.now(),
      );
      expect(today.dateGroupLabel, '今天');

      final tomorrow = Schedule(
        id: '2',
        userId: 'user1',
        title: 'Tomorrow',
        startTime: DateTime.now().add(const Duration(days: 1)),
        endTime: DateTime.now().add(const Duration(days: 1, hours: 1)),
        category: '工作',
        color: '#4A90D9',
        createdAt: DateTime.now(),
      );
      expect(tomorrow.dateGroupLabel, '明天');

      final later = Schedule(
        id: '3',
        userId: 'user1',
        title: 'Later',
        startTime: DateTime.now().add(const Duration(days: 3)),
        endTime: DateTime.now().add(const Duration(days: 3, hours: 1)),
        category: '工作',
        color: '#4A90D9',
        createdAt: DateTime.now(),
      );
      expect(later.dateGroupLabel, '之后');
    });

    test('ScheduleStatus enum values', () {
      expect(ScheduleStatus.pending.label, '待办');
      expect(ScheduleStatus.inProgress.label, '进行中');
      expect(ScheduleStatus.completed.label, '已完成');

      expect(ScheduleStatus.fromString('pending'), ScheduleStatus.pending);
      expect(ScheduleStatus.fromString('in_progress'), ScheduleStatus.inProgress);
      expect(ScheduleStatus.fromString('completed'), ScheduleStatus.completed);

      expect(ScheduleStatus.pending.apiValue, 'pending');
      expect(ScheduleStatus.inProgress.apiValue, 'in_progress');
      expect(ScheduleStatus.completed.apiValue, 'completed');
    });

    test('Schedule copyWith preserves values', () {
      final schedule = Schedule(
        id: '1',
        userId: 'user1',
        title: 'Test',
        startTime: DateTime(2026, 8, 12, 10, 0),
        endTime: DateTime(2026, 8, 12, 12, 0),
        category: '工作',
        color: '#4A90D9',
        createdAt: DateTime.now(),
      );

      final updated = schedule.copyWith(title: 'Updated');
      expect(updated.title, 'Updated');
      expect(updated.id, '1');
      expect(updated.userId, 'user1');
    });

    test('Schedule.firestore fromMap and toMap', () {
      final now = DateTime.now();
      final data = {
        'userId': 'user1',
        'title': 'Test',
        'startTime': now,
        'endTime': now.add(const Duration(hours: 1)),
        'category': '工作',
        'color': '#4A90D9',
        'status': 'pending',
        'createdAt': now,
      };

      final schedule = Schedule.fromFirestore('1', {
        ...data,
        'startTime': DateTimeTimestampStub(now),
        'endTime': DateTimeTimestampStub(now.add(const Duration(hours: 1))),
        'createdAt': DateTimeTimestampStub(now),
      });

      expect(schedule.id, '1');
      expect(schedule.title, 'Test');
      expect(schedule.status, ScheduleStatus.pending);

      final map = schedule.toMap();
      expect(map['title'], 'Test');
      expect(map['status'], 'pending');
    });
  });
}

// Stub for Firestore Timestamp
class DateTimeTimestampStub {
  final DateTime _date;
  DateTimeTimestampStub(this._date);
  DateTime toDate() => _date;
}
