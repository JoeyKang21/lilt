import '../models/schedule.dart';

/// 日程数据仓库接口
/// 抽象数据访问层，支持 Firestore 和本地存储两种实现
abstract class ScheduleRepository {
  /// 获取日程列表（实时流）
  Stream<List<Schedule>> getSchedules(String userId);

  /// 获取日程列表（单次）
  Future<List<Schedule>> getSchedulesOnce(String userId);

  /// 新增日程
  Future<String> addSchedule(String userId, Schedule schedule);

  /// 更新日程
  Future<void> updateSchedule(
    String userId,
    String scheduleId,
    Map<String, dynamic> data,
  );

  /// 删除日程
  Future<void> deleteSchedule(String userId, String scheduleId);

  /// 创建用户文档
  Future<void> createUserDocument(String userId, String email);
}
