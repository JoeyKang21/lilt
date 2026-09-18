import 'package:flutter_test/flutter_test.dart';
import 'package:lilt/core/validators/validators.dart';
import 'package:lilt/data/models/schedule.dart';

void main() {
  group('ScheduleValidator', () {
    group('validateTitle', () {
      test('returns failure for null title', () {
        final result = ScheduleValidator.validateTitle(null);
        expect(result.isValid, isFalse);
        expect(result.errorMessage, '标题不能为空');
      });

      test('returns failure for empty title', () {
        final result = ScheduleValidator.validateTitle('   ');
        expect(result.isValid, isFalse);
        expect(result.errorMessage, '标题不能为空');
      });

      test('returns failure for title exceeding 200 chars', () {
        final longTitle = 'a' * 201;
        final result = ScheduleValidator.validateTitle(longTitle);
        expect(result.isValid, isFalse);
        expect(result.errorMessage, '标题不能超过200个字符');
      });

      test('returns success for valid title', () {
        final result = ScheduleValidator.validateTitle('项目评审会议');
        expect(result.isValid, isTrue);
        expect(result.errorMessage, isNull);
      });

      test('returns success for title exactly 200 chars', () {
        final title = 'a' * 200;
        final result = ScheduleValidator.validateTitle(title);
        expect(result.isValid, isTrue);
      });
    });

    group('validateTimeRange', () {
      test('returns failure for null start time', () {
        final result = ScheduleValidator.validateTimeRange(
          null,
          DateTime.now(),
        );
        expect(result.isValid, isFalse);
      });

      test('returns failure for null end time', () {
        final result = ScheduleValidator.validateTimeRange(
          DateTime.now(),
          null,
        );
        expect(result.isValid, isFalse);
      });

      test('returns failure when start is after end', () {
        final result = ScheduleValidator.validateTimeRange(
          DateTime(2026, 8, 12, 14, 0),
          DateTime(2026, 8, 12, 10, 0),
        );
        expect(result.isValid, isFalse);
        expect(result.errorMessage, '开始时间不能晚于结束时间');
      });

      test('returns failure when start equals end', () {
        final time = DateTime(2026, 8, 12, 10, 0);
        final result = ScheduleValidator.validateTimeRange(time, time);
        expect(result.isValid, isFalse);
        expect(result.errorMessage, '开始时间和结束时间不能相同');
      });

      test('returns success for valid time range', () {
        final result = ScheduleValidator.validateTimeRange(
          DateTime(2026, 8, 12, 10, 0),
          DateTime(2026, 8, 12, 12, 0),
        );
        expect(result.isValid, isTrue);
      });
    });

    group('validateCategory', () {
      test('returns failure for null category', () {
        final result = ScheduleValidator.validateCategory(null);
        expect(result.isValid, isFalse);
      });

      test('returns failure for empty category', () {
        final result = ScheduleValidator.validateCategory('');
        expect(result.isValid, isFalse);
      });

      test('returns failure for invalid category', () {
        final result = ScheduleValidator.validateCategory('运动');
        expect(result.isValid, isFalse);
        expect(result.errorMessage, contains('无效的分类'));
      });

      test('returns success for valid category', () {
        final result = ScheduleValidator.validateCategory('工作');
        expect(result.isValid, isTrue);
      });

      test('returns success for all default categories', () {
        for (final cat in ['工作', '个人', '学习', '健康', '社交', '其他']) {
          expect(
            ScheduleValidator.validateCategory(cat).isValid,
            isTrue,
            reason: 'Category $cat should be valid',
          );
        }
      });
    });

    group('validateColor', () {
      test('returns failure for null color', () {
        final result = ScheduleValidator.validateColor(null);
        expect(result.isValid, isFalse);
      });

      test('returns failure for empty color', () {
        final result = ScheduleValidator.validateColor('');
        expect(result.isValid, isFalse);
      });

      test('returns failure for invalid color format', () {
        final result = ScheduleValidator.validateColor('red');
        expect(result.isValid, isFalse);
      });

      test('returns failure for color without hash', () {
        final result = ScheduleValidator.validateColor('4A90D9');
        expect(result.isValid, isFalse);
      });

      test('returns success for valid hex color', () {
        final result = ScheduleValidator.validateColor('#4A90D9');
        expect(result.isValid, isTrue);
      });

      test('returns success for lowercase hex color', () {
        final result = ScheduleValidator.validateColor('#ff6b6b');
        expect(result.isValid, isTrue);
      });
    });

    group('validateStatus', () {
      test('returns failure for null status', () {
        final result = ScheduleValidator.validateStatus(null);
        expect(result.isValid, isFalse);
      });

      test('returns failure for invalid status', () {
        final result = ScheduleValidator.validateStatus('done');
        expect(result.isValid, isFalse);
      });

      test('returns success for pending', () {
        final result = ScheduleValidator.validateStatus('pending');
        expect(result.isValid, isTrue);
      });

      test('returns success for in_progress', () {
        final result = ScheduleValidator.validateStatus('in_progress');
        expect(result.isValid, isTrue);
      });

      test('returns success for completed', () {
        final result = ScheduleValidator.validateStatus('completed');
        expect(result.isValid, isTrue);
      });
    });

    group('validateDescription', () {
      test('returns success for null description', () {
        final result = ScheduleValidator.validateDescription(null);
        expect(result.isValid, isTrue);
      });

      test('returns success for empty description', () {
        final result = ScheduleValidator.validateDescription('');
        expect(result.isValid, isTrue);
      });

      test('returns success for valid description', () {
        final result = ScheduleValidator.validateDescription('这是一段描述');
        expect(result.isValid, isTrue);
      });

      test('returns failure for description exceeding 2000 chars', () {
        final longDesc = 'a' * 2001;
        final result = ScheduleValidator.validateDescription(longDesc);
        expect(result.isValid, isFalse);
      });

      test('returns success for description exactly 2000 chars', () {
        final desc = 'a' * 2000;
        final result = ScheduleValidator.validateDescription(desc);
        expect(result.isValid, isTrue);
      });
    });

    group('validate (full)', () {
      final validData = ScheduleData(
        title: '测试日程',
        description: '测试描述',
        startTime: DateTime(2026, 8, 12, 10, 0),
        endTime: DateTime(2026, 8, 12, 12, 0),
        category: '工作',
        color: '#4A90D9',
        status: 'pending',
      );

      test('returns success for valid data', () {
        final result = ScheduleValidator.validate(validData);
        expect(result.isValid, isTrue);
      });

      test('returns failure for invalid title', () {
        final data = ScheduleData(
          title: '',
          description: '',
          startTime: DateTime(2026, 8, 12, 10, 0),
          endTime: DateTime(2026, 8, 12, 12, 0),
          category: '工作',
          color: '#4A90D9',
          status: 'pending',
        );
        final result = ScheduleValidator.validate(data);
        expect(result.isValid, isFalse);
        expect(result.errorMessage, '标题不能为空');
      });

      test('returns failure for invalid time range', () {
        final data = ScheduleData(
          title: 'Test',
          description: '',
          startTime: DateTime(2026, 8, 12, 14, 0),
          endTime: DateTime(2026, 8, 12, 10, 0),
          category: '工作',
          color: '#4A90D9',
          status: 'pending',
        );
        final result = ScheduleValidator.validate(data);
        expect(result.isValid, isFalse);
        expect(result.errorMessage, '开始时间不能晚于结束时间');
      });
    });
  });

  group('ScheduleData', () {
    test('fromSchedule creates valid ScheduleData', () {
      final schedule = Schedule(
        id: '1',
        userId: 'user-1',
        title: 'Test',
        description: 'Desc',
        startTime: DateTime(2026, 8, 12, 10, 0),
        endTime: DateTime(2026, 8, 12, 12, 0),
        category: '工作',
        color: '#4A90D9',
        status: ScheduleStatus.inProgress,
        createdAt: DateTime.now(),
      );

      final data = ScheduleData.fromSchedule(schedule);
      expect(data.title, 'Test');
      expect(data.status, 'in_progress');
      expect(data.category, '工作');
    });

    test('toFirestoreMap produces correct map', () {
      final data = ScheduleData(
        title: '  Test  ',
        description: 'Desc',
        startTime: DateTime(2026, 8, 12, 10, 0),
        endTime: DateTime(2026, 8, 12, 12, 0),
        category: '工作',
        color: '#4A90D9',
        status: 'pending',
      );

      final map = data.toFirestoreMap('user-123');
      expect(map['userId'], 'user-123');
      expect(map['title'], 'Test'); // trimmed
      expect(map['status'], 'pending');
      expect(map['createdAt'], isA<DateTime>());
    });
  });

  group('ValidationResult', () {
    test('success creates valid result', () {
      final result = ValidationResult.success();
      expect(result.isValid, isTrue);
      expect(result.errorMessage, isNull);
    });

    test('failure creates invalid result with message', () {
      final result = ValidationResult.failure('测试错误');
      expect(result.isValid, isFalse);
      expect(result.errorMessage, '测试错误');
    });
  });
}
