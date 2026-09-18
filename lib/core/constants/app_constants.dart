import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Lilt';
  static const String schedulesCollection = 'schedules';
  static const String usersCollection = 'users';

  static const List<String> defaultCategories = [
    '工作',
    '个人',
    '学习',
    '健康',
    '社交',
    '其他',
  ];

  static const List<String> categoryColors = [
    '#4A90D9',
    '#50C878',
    '#FF6B6B',
    '#FFD93D',
    '#9B59B6',
    '#95A5A6',
  ];

  static String colorForCategory(String category) {
    final index = defaultCategories.indexOf(category);
    if (index >= 0 && index < categoryColors.length) {
      return categoryColors[index];
    }
    return '#4A90D9';
  }

  static Color parseColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }
}
