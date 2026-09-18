import '../../data/models/schedule.dart';
import '../constants/app_constants.dart';

/// 日程数据校验结果
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult._({required this.isValid, this.errorMessage});

  factory ValidationResult.success() =>
      const ValidationResult._(isValid: true);

  factory ValidationResult.failure(String message) =>
      ValidationResult._(isValid: false, errorMessage: message);
}

/// 业务层数据校验器
class ScheduleValidator {
  ScheduleValidator._();

  /// 校验日程创建/编辑的完整数据
  static ValidationResult validate(ScheduleData data) {
    // 标题校验
    final titleResult = validateTitle(data.title);
    if (!titleResult.isValid) return titleResult;

    // 时间校验
    final timeResult = validateTimeRange(data.startTime, data.endTime);
    if (!timeResult.isValid) return timeResult;

    // 分类校验
    final categoryResult = validateCategory(data.category);
    if (!categoryResult.isValid) return categoryResult;

    // 颜色校验
    final colorResult = validateColor(data.color);
    if (!colorResult.isValid) return colorResult;

    // 状态校验
    final statusResult = validateStatus(data.status);
    if (!statusResult.isValid) return statusResult;

    // 描述校验
    final descResult = validateDescription(data.description);
    if (!descResult.isValid) return descResult;

    return ValidationResult.success();
  }

  /// 校验标题
  static ValidationResult validateTitle(String? title) {
    if (title == null || title.trim().isEmpty) {
      return ValidationResult.failure('标题不能为空');
    }
    if (title.trim().length > 200) {
      return ValidationResult.failure('标题不能超过200个字符');
    }
    return ValidationResult.success();
  }

  /// 校验时间范围
  static ValidationResult validateTimeRange(DateTime? start, DateTime? end) {
    if (start == null || end == null) {
      return ValidationResult.failure('开始时间和结束时间不能为空');
    }
    if (start.isAfter(end)) {
      return ValidationResult.failure('开始时间不能晚于结束时间');
    }
    if (start.isAtSameMomentAs(end)) {
      return ValidationResult.failure('开始时间和结束时间不能相同');
    }
    return ValidationResult.success();
  }

  /// 校验分类
  static ValidationResult validateCategory(String? category) {
    if (category == null || category.trim().isEmpty) {
      return ValidationResult.failure('分类不能为空');
    }
    if (!AppConstants.defaultCategories.contains(category.trim())) {
      return ValidationResult.failure('无效的分类：$category');
    }
    return ValidationResult.success();
  }

  /// 校验颜色
  static ValidationResult validateColor(String? color) {
    if (color == null || color.trim().isEmpty) {
      return ValidationResult.failure('颜色标记不能为空');
    }
    final hexPattern = RegExp(r'^#[0-9a-fA-F]{6}$');
    if (!hexPattern.hasMatch(color.trim())) {
      return ValidationResult.failure('无效的颜色格式');
    }
    return ValidationResult.success();
  }

  /// 校验状态
  static ValidationResult validateStatus(String? status) {
    if (status == null) {
      return ValidationResult.failure('状态不能为空');
    }
    const validStatuses = ['pending', 'in_progress', 'completed'];
    if (!validStatuses.contains(status)) {
      return ValidationResult.failure('无效的状态值：$status');
    }
    return ValidationResult.success();
  }

  /// 校验描述
  static ValidationResult validateDescription(String? description) {
    if (description != null && description.length > 2000) {
      return ValidationResult.failure('描述不能超过2000个字符');
    }
    return ValidationResult.success();
  }
}

/// 日程数据传输对象（用于校验层）
class ScheduleData {
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String category;
  final String color;
  final String status;

  const ScheduleData({
    required this.title,
    this.description = '',
    required this.startTime,
    required this.endTime,
    required this.category,
    required this.color,
    required this.status,
  });

  factory ScheduleData.fromSchedule(Schedule schedule) {
    return ScheduleData(
      title: schedule.title,
      description: schedule.description,
      startTime: schedule.startTime,
      endTime: schedule.endTime,
      category: schedule.category,
      color: schedule.color,
      status: schedule.status.apiValue,
    );
  }

  Map<String, dynamic> toFirestoreMap(String userId) {
    return {
      'userId': userId,
      'title': title.trim(),
      'description': description.trim(),
      'startTime': startTime,
      'endTime': endTime,
      'category': category,
      'color': color,
      'status': status,
      'createdAt': DateTime.now(),
    };
  }
}
