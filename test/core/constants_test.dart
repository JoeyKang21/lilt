import 'package:flutter_test/flutter_test.dart';
import 'package:lilt/core/constants/app_constants.dart';

void main() {
  group('AppConstants', () {
    test('defaultCategories contains expected values', () {
      expect(AppConstants.defaultCategories, [
        '工作',
        '个人',
        '学习',
        '健康',
        '社交',
        '其他',
      ]);
    });

    test('categoryColors has matching count with categories', () {
      expect(
        AppConstants.categoryColors.length,
        AppConstants.defaultCategories.length,
      );
    });

    test('colorForCategory returns correct color for known category', () {
      expect(AppConstants.colorForCategory('工作'), '#4A90D9');
      expect(AppConstants.colorForCategory('个人'), '#50C878');
      expect(AppConstants.colorForCategory('学习'), '#FF6B6B');
      expect(AppConstants.colorForCategory('健康'), '#FFD93D');
      expect(AppConstants.colorForCategory('社交'), '#9B59B6');
      expect(AppConstants.colorForCategory('其他'), '#95A5A6');
    });

    test('colorForCategory returns default for unknown category', () {
      expect(AppConstants.colorForCategory('未知分类'), '#4A90D9');
    });

    test('parseColor returns correct Color', () {
      final color = AppConstants.parseColor('#4A90D9');
      expect(color, isNotNull);
    });

    test('parseColor handles missing hash', () {
      final color = AppConstants.parseColor('4A90D9');
      expect(color, isNotNull);
    });
  });
}
