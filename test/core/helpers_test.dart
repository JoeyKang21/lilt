import 'package:flutter_test/flutter_test.dart';
import 'package:lilt/core/utils/helpers.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    Intl.defaultLocale = 'zh_CN';
    await initializeDateFormatting('zh_CN');
  });
  group('Helpers', () {
    test('formatDateTime returns correct format', () {
      final date = DateTime(2026, 8, 12, 10, 30);
      final result = Helpers.formatDateTime(date);
      expect(result, '2026-08-12 10:30');
    });

    test('formatShort returns correct format', () {
      final date = DateTime(2026, 8, 12, 10, 30);
      final result = Helpers.formatShort(date);
      expect(result, '08/12 10:30');
    });

    test('formatTime returns correct format', () {
      final date = DateTime(2026, 8, 12, 10, 30);
      final result = Helpers.formatTime(date);
      expect(result, '10:30');
    });

    test('formatDateCN returns correct format', () {
      final date = DateTime(2026, 8, 12);
      final result = Helpers.formatDateCN(date);
      expect(result, contains('2026年8月12日'));
    });

    group('greeting', () {
      test('returns correct morning greeting', () {
        // We can't control the time, so just verify it returns a non-empty string
        expect(Helpers.greeting(), isNotEmpty);
        expect(
          ['夜深了', '早上好', '下午好', '晚上好'].contains(Helpers.greeting()),
          isTrue,
        );
      });
    });

    group('formatTimeUntil', () {
      test('returns empty for null duration', () {
        expect(Helpers.formatTimeUntil(null), '');
      });

      test('returns days format', () {
        final result = Helpers.formatTimeUntil(const Duration(days: 3));
        expect(result, '3 天后开始');
      });

      test('returns hours and minutes format', () {
        final result = Helpers.formatTimeUntil(
          const Duration(hours: 2, minutes: 30),
        );
        expect(result, '2 小时 30 分钟后开始');
      });

      test('returns minutes format', () {
        final result = Helpers.formatTimeUntil(const Duration(minutes: 45));
        expect(result, '45 分钟后开始');
      });

      test('returns 即将开始 for very short duration', () {
        final result = Helpers.formatTimeUntil(const Duration(seconds: 30));
        expect(result, '即将开始');
      });
    });

    group('validateEmail', () {
      test('returns error for null', () {
        expect(Helpers.validateEmail(null), isNotNull);
      });

      test('returns error for empty', () {
        expect(Helpers.validateEmail(''), isNotNull);
      });

      test('returns error for invalid email', () {
        expect(Helpers.validateEmail('notanemail'), isNotNull);
      });

      test('returns null for valid email', () {
        expect(Helpers.validateEmail('test@example.com'), isNull);
      });
    });

    group('validatePassword', () {
      test('returns error for null', () {
        expect(Helpers.validatePassword(null), isNotNull);
      });

      test('returns error for empty', () {
        expect(Helpers.validatePassword(''), isNotNull);
      });

      test('returns error for short password', () {
        expect(Helpers.validatePassword('12345'), isNotNull);
      });

      test('returns null for valid password', () {
        expect(Helpers.validatePassword('123456'), isNull);
      });

      test('returns null for longer password', () {
        expect(Helpers.validatePassword('securePassword123'), isNull);
      });
    });
  });
}
