import 'package:intl/intl.dart';

/// 通用工具函数
class Helpers {
  Helpers._();

  /// 日期格式化：yyyy-MM-dd HH:mm
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  /// 日期格式化：MM/dd HH:mm
  static String formatShort(DateTime dateTime) {
    return DateFormat('MM/dd HH:mm').format(dateTime);
  }

  /// 时间格式化：HH:mm
  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  /// 日期格式化：yyyy年M月d日 EEEE
  static String formatDateCN(DateTime dateTime) {
    return DateFormat('yyyy年M月d日 EEEE', 'zh_CN').format(dateTime);
  }

  /// 根据当前时间返回问候语
  static String greeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return '夜深了';
    if (hour < 12) return '早上好';
    if (hour < 18) return '下午好';
    return '晚上好';
  }

  /// 格式化时间差
  static String formatTimeUntil(Duration? duration) {
    if (duration == null) return '';
    if (duration.inDays > 0) return '${duration.inDays} 天后开始';
    if (duration.inHours > 0) {
      return '${duration.inHours} 小时 ${duration.inMinutes % 60} 分钟后开始';
    }
    if (duration.inMinutes > 0) return '${duration.inMinutes} 分钟后开始';
    return '即将开始';
  }

  /// 验证邮箱格式
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return '请输入邮箱';
    if (!value.contains('@') || !value.contains('.')) return '请输入有效的邮箱地址';
    return null;
  }

  /// 验证密码强度
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return '请输入密码';
    if (value.length < 6) return '密码至少6位';
    return null;
  }
}
