import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/services/auth_service.dart';
import '../data/services/export_service.dart';
import '../data/repositories/schedule_repository.dart';
import '../data/repositories/firestore_schedule_repository.dart';
import '../data/models/schedule.dart';

// Services
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final exportServiceProvider = Provider<ExportService>((ref) => ExportService());

// Repository
final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  return FirestoreScheduleRepository();
});

// Auth state
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});

// Schedules
final schedulesProvider = StreamProvider<List<Schedule>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(scheduleRepositoryProvider).getSchedules(user.uid);
});

// Filter state
enum ScheduleFilterStatus {
  all,
  pending,
  inProgress,
  completed;

  String get label {
    switch (this) {
      case ScheduleFilterStatus.all:
        return '全部';
      case ScheduleFilterStatus.pending:
        return '待办';
      case ScheduleFilterStatus.inProgress:
        return '进行中';
      case ScheduleFilterStatus.completed:
        return '已完成';
    }
  }
}

final filterStatusProvider = StateProvider<ScheduleFilterStatus>(
  (ref) => ScheduleFilterStatus.all,
);

final filterCategoryProvider = StateProvider<String?>((ref) => null);

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredSchedulesProvider = Provider<List<Schedule>>((ref) {
  final schedules = ref.watch(schedulesProvider).valueOrNull ?? [];
  final statusFilter = ref.watch(filterStatusProvider);
  final categoryFilter = ref.watch(filterCategoryProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();

  var result = schedules;

  if (statusFilter != ScheduleFilterStatus.all) {
    result = result.where((s) {
      switch (statusFilter) {
        case ScheduleFilterStatus.pending:
          return s.status == ScheduleStatus.pending;
        case ScheduleFilterStatus.inProgress:
          return s.status == ScheduleStatus.inProgress;
        case ScheduleFilterStatus.completed:
          return s.status == ScheduleStatus.completed;
        default:
          return true;
      }
    }).toList();
  }

  if (categoryFilter != null && categoryFilter.isNotEmpty) {
    result = result.where((s) => s.category == categoryFilter).toList();
  }

  if (searchQuery.isNotEmpty) {
    result = result
        .where(
          (s) =>
              s.title.toLowerCase().contains(searchQuery) ||
              s.description.toLowerCase().contains(searchQuery),
        )
        .toList();
  }

  return result;
});

// Statistics period
enum StatisticsPeriod { week, month, year }

final statisticsPeriodProvider = StateProvider<StatisticsPeriod>(
  (ref) => StatisticsPeriod.week,
);

// View mode
enum ViewMode { list, gantt, calendar }

final viewModeProvider = StateProvider<ViewMode>((ref) => ViewMode.list);

// Current tab index for bottom navigation (0=主页, 1=统计, 2=我的)
final currentTabProvider = StateProvider<int>((ref) => 0);
