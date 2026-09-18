import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/providers.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/schedule.dart';
import 'list_view/list_view_page.dart';
import 'gantt_view/gantt_view_page.dart';
import 'calendar_view/calendar_view_page.dart';
import 'detail/schedule_detail_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(currentTabProvider);
    const pages = [
      HomePageContent(),
      StatisticsPage(),
      ProfilePage(),
    ];

    return Scaffold(
      body: pages[currentTab],
      floatingActionButton: currentTab == 0
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ScheduleDetailPage(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentTab,
        onDestinationSelected: (index) {
          ref.read(currentTabProvider.notifier).state = index;
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '主页',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: '统计',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}

class HomePageContent extends ConsumerWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(viewModeProvider);
    final schedulesAsync = ref.watch(schedulesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _greeting(),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            Text(
              DateFormat('yyyy年M月d日 EEEE', 'zh_CN').format(DateTime.now()),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _ScheduleSearchDelegate(ref),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Today overview card
          schedulesAsync.when(
            data: (schedules) => _TodayOverviewCard(schedules: schedules),
            loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
            error: (_, __) => const SizedBox(height: 100, child: Center(child: Text('加载失败'))),
          ),
          // View mode tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<ViewMode>(
                    segments: const [
                      ButtonSegment(value: ViewMode.list, label: Text('列表')),
                      ButtonSegment(
                        value: ViewMode.gantt,
                        label: Text('甘特图'),
                      ),
                      ButtonSegment(
                        value: ViewMode.calendar,
                        label: Text('日历'),
                      ),
                    ],
                    selected: {viewMode},
                    onSelectionChanged: (selected) {
                      ref.read(viewModeProvider.notifier).state =
                          selected.first;
                    },
                  ),
                ),
              ],
            ),
          ),
          // Filter bar
          const _FilterBar(),
          // Content
          Expanded(
            child: _buildView(ref, viewMode),
          ),
        ],
      ),
    );
  }

  Widget _buildView(WidgetRef ref, ViewMode mode) {
    final filtered = ref.watch(filteredSchedulesProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(schedulesProvider);
        await ref.read(schedulesProvider.future);
      },
      child: switch (mode) {
        ViewMode.list => ScheduleListView(schedules: filtered),
        ViewMode.gantt => GanttViewPage(schedules: filtered),
        ViewMode.calendar => CalendarViewPage(schedules: filtered),
      },
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '早上好';
    if (hour < 18) return '下午好';
    return '晚上好';
  }
}

class _TodayOverviewCard extends StatelessWidget {
  final List<Schedule> schedules;

  const _TodayOverviewCard({required this.schedules});

  @override
  Widget build(BuildContext context) {
    final todaySchedules =
        schedules.where((s) => s.isToday).toList();

    final upcomingSchedules = schedules
        .where(
          (s) => s.startTime.isAfter(DateTime.now()),
        )
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    final nextSchedule = upcomingSchedules.isNotEmpty ? upcomingSchedules.first : null;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '今日概览',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${todaySchedules.length} 项日程',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (nextSchedule != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '下一项：${nextSchedule.title}',
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _formatTimeUntil(nextSchedule.timeUntilStart()),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ] else
              Text(
                '今日暂无日程安排',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTimeUntil(Duration? duration) {
    if (duration == null) return '';
    if (duration.inDays > 0) {
      return '${duration.inDays} 天后开始';
    }
    if (duration.inHours > 0) {
      return '${duration.inHours} 小时 ${duration.inMinutes % 60} 分钟后开始';
    }
    if (duration.inMinutes > 0) {
      return '${duration.inMinutes} 分钟后开始';
    }
    return '即将开始';
  }
}

class _FilterBar extends ConsumerWidget {
  const _FilterBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStatus = ref.watch(filterStatusProvider);
    final currentCategory = ref.watch(filterCategoryProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Status filter chips
          ...ScheduleFilterStatus.values.map((status) {
            final isSelected = currentStatus == status;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(status.label),
                selected: isSelected,
                onSelected: (_) {
                  ref.read(filterStatusProvider.notifier).state = status;
                },
              ),
            );
          }),
          const SizedBox(width: 8),
          const VerticalDivider(),
          const SizedBox(width: 8),
          // Category filter chips
          FilterChip(
            label: const Text('全部分类'),
            selected: currentCategory == null,
            onSelected: (_) {
              ref.read(filterCategoryProvider.notifier).state = null;
            },
          ),
          ...AppConstants.defaultCategories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: FilterChip(
                label: Text(category),
                selected: currentCategory == category,
                onSelected: (_) {
                  final notifier = ref.read(filterCategoryProvider.notifier);
                  notifier.state =
                      notifier.state == category ? null : category;
                },
                avatar: CircleAvatar(
                  radius: 6,
                  backgroundColor: AppConstants.parseColor(
                    AppConstants.colorForCategory(category),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ScheduleSearchDelegate extends SearchDelegate<String> {
  final WidgetRef ref;

  _ScheduleSearchDelegate(this.ref);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final schedules = ref.watch(schedulesProvider).valueOrNull ?? [];
    final results = schedules.where((s) {
      return s.title.toLowerCase().contains(query.toLowerCase()) ||
          s.description.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final schedule = results[index];
        final dateFormat = DateFormat('MM-dd HH:mm');
        return ListTile(
          leading: Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: AppConstants.parseColor(schedule.color),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          title: Text(schedule.title),
          subtitle: Text(
            '${dateFormat.format(schedule.startTime)} ~ ${dateFormat.format(schedule.endTime)}',
          ),
          trailing: _StatusChip(status: schedule.status),
          onTap: () async {
            close(context, '');
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ScheduleDetailPage(schedule: schedule),
              ),
            );
          },
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  final ScheduleStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case ScheduleStatus.pending:
        color = Colors.orange;
      case ScheduleStatus.inProgress:
        color = Colors.blue;
      case ScheduleStatus.completed:
        color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.label,
        style: TextStyle(fontSize: 12, color: color),
      ),
    );
  }
}

// Statistics Page
class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(statisticsPeriodProvider);
    final schedulesAsync = ref.watch(schedulesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('数据统计')),
      body: schedulesAsync.when(
        data: (schedules) {
          final filtered = _filterByPeriod(schedules, period, ref);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Period switcher
                SegmentedButton<StatisticsPeriod>(
                  segments: const [
                    ButtonSegment(
                      value: StatisticsPeriod.week,
                      label: Text('本周'),
                    ),
                    ButtonSegment(
                      value: StatisticsPeriod.month,
                      label: Text('本月'),
                    ),
                    ButtonSegment(
                      value: StatisticsPeriod.year,
                      label: Text('全年'),
                    ),
                  ],
                  selected: {period},
                  onSelectionChanged: (selected) {
                    ref.read(statisticsPeriodProvider.notifier).state =
                        selected.first;
                  },
                ),
                const SizedBox(height: 24),
                // Overview cards
                _OverviewCards(
                  total: filtered.length,
                  completed: filtered
                      .where((s) => s.status == ScheduleStatus.completed)
                      .length,
                ),
                const SizedBox(height: 24),
                // Status distribution
                Text(
                  '状态分布',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _StatusDistribution(schedules: filtered),
                const SizedBox(height: 24),
                // Category distribution
                Text(
                  '分类占比',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _CategoryDistribution(schedules: filtered),
                const SizedBox(height: 24),
                // Completion trend
                Text(
                  '完成趋势',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _CompletionTrend(schedules: filtered, period: period),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('加载失败')),
      ),
    );
  }

  List<Schedule> _filterByPeriod(
    List<Schedule> schedules,
    StatisticsPeriod period,
    WidgetRef ref,
  ) {
    final now = DateTime.now();
    DateTime start;
    switch (period) {
      case StatisticsPeriod.week:
        start = now.subtract(Duration(days: now.weekday - 1));
        start = DateTime(start.year, start.month, start.day);
      case StatisticsPeriod.month:
        start = DateTime(now.year, now.month, 1);
      case StatisticsPeriod.year:
        start = DateTime(now.year, 1, 1);
    }
    return schedules.where((s) => s.startTime.isAfter(start.subtract(const Duration(days: 1)))).toList();
  }
}

class _OverviewCards extends StatelessWidget {
  final int total;
  final int completed;

  const _OverviewCards({required this.total, required this.completed});

  @override
  Widget build(BuildContext context) {
    final completionRate = total > 0 ? completed / total : 0.0;

    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    '$total',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '总日程数',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    '$completed',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '已完成',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: completionRate,
                          strokeWidth: 4,
                          color: Theme.of(context).colorScheme.primary,
                          backgroundColor:
                              Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                        Text(
                          '${(completionRate * 100).toInt()}%',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '完成率',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusDistribution extends StatelessWidget {
  final List<Schedule> schedules;

  const _StatusDistribution({required this.schedules});

  @override
  Widget build(BuildContext context) {
    final pending = schedules.where((s) => s.status == ScheduleStatus.pending).length;
    final inProgress = schedules.where((s) => s.status == ScheduleStatus.inProgress).length;
    final completed = schedules.where((s) => s.status == ScheduleStatus.completed).length;
    final total = schedules.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _StatusBar(
              label: '待办',
              count: pending,
              total: total,
              color: Colors.orange,
              targetFilter: ScheduleFilterStatus.pending,
            ),
            const SizedBox(height: 12),
            _StatusBar(
              label: '进行中',
              count: inProgress,
              total: total,
              color: Colors.blue,
              targetFilter: ScheduleFilterStatus.inProgress,
            ),
            const SizedBox(height: 12),
            _StatusBar(
              label: '已完成',
              count: completed,
              total: total,
              color: Colors.green,
              targetFilter: ScheduleFilterStatus.completed,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBar extends ConsumerWidget {
  final String label;
  final int count;
  final int total;
  final Color color;
  final ScheduleFilterStatus? targetFilter;

  const _StatusBar({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
    this.targetFilter,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratio = total > 0 ? count / total : 0.0;
    final row = Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 12,
              backgroundColor: color.withAlpha(30),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text(
            '$count',
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        if (targetFilter != null) ...[
          const SizedBox(width: 4),
          Icon(
            Icons.chevron_right,
            size: 18,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ],
      ],
    );

    if (targetFilter != null) {
      return InkWell(
        onTap: () {
          ref.read(filterStatusProvider.notifier).state = targetFilter!;
          ref.read(currentTabProvider.notifier).state = 0;
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: row,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: row,
    );
  }
}

class _CategoryDistribution extends ConsumerWidget {
  final List<Schedule> schedules;

  const _CategoryDistribution({required this.schedules});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Map<String, int> categoryCounts = {};
    for (final s in schedules) {
      categoryCounts[s.category] = (categoryCounts[s.category] ?? 0) + 1;
    }

    final entries = categoryCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: entries.map((entry) {
            final ratio = schedules.isNotEmpty ? entry.value / schedules.length : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () {
                  ref.read(filterCategoryProvider.notifier).state = entry.key;
                  ref.read(currentTabProvider.notifier).state = 0;
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 6,
                        backgroundColor: AppConstants.parseColor(
                          AppConstants.colorForCategory(entry.key),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 50,
                        child: Text(entry.key),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 8,
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 40,
                        child: Text(
                          '${entry.value}',
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _CompletionTrend extends StatelessWidget {
  final List<Schedule> schedules;
  final StatisticsPeriod period;

  const _CompletionTrend({required this.schedules, required this.period});

  @override
  Widget build(BuildContext context) {
    final completedSchedules =
        schedules.where((s) => s.status == ScheduleStatus.completed).toList();

    // Group by date and count
    final Map<String, int> dailyCounts = {};
    final dateFormat = DateFormat('MM/dd');
    for (final s in completedSchedules) {
      final key = dateFormat.format(s.createdAt);
      dailyCounts[key] = (dailyCounts[key] ?? 0) + 1;
    }

    final entries = dailyCounts.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    if (entries.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('暂无完成记录')),
        ),
      );
    }

    final maxCount = entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 150,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: entries.map((entry) {
              final height = maxCount > 0 ? (entry.value / maxCount * 100).toDouble() : 0.0;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${entry.value}',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: height,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry.key,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// Profile Page
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: user != null
                  ? Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          child: Text(
                            user.email![0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 24,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.email!,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '注册时间：${DateFormat('yyyy-MM-dd').format(user.metadata.creationTime ?? DateTime.now())}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : const Center(
                      child: Text('请先登录'),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          // Export
          Card(
            child: ListTile(
              leading: const Icon(Icons.file_download_outlined),
              title: const Text('导出日程'),
              subtitle: const Text('导出为 TXT 文件'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _exportSchedules(context, ref),
            ),
          ),
          const SizedBox(height: 8),
          // Sync status
          const Card(
            child: ListTile(
              leading: Icon(Icons.sync),
              title: Text('数据同步'),
              subtitle: Text('Firestore 实时同步'),
              trailing: Icon(Icons.check_circle, color: Colors.green, size: 20),
            ),
          ),
          const SizedBox(height: 8),
          // About
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('关于'),
              subtitle: const Text('Lilt v1.0.0'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Lilt',
                  applicationVersion: '1.0.0',
                  applicationLegalese: '日程管理 App',
                );
              },
            ),
          ),
          if (user != null) ...[
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('退出登录'),
                    content: const Text('确定要退出登录吗？本地数据将保留。'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('确定'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await ref.read(authServiceProvider).signOut();
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('退出登录'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _exportSchedules(BuildContext context, WidgetRef ref) async {
    final schedules = ref.read(schedulesProvider).valueOrNull ?? [];
    if (schedules.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('没有日程可导出')),
        );
      }
      return;
    }
    try {
      final exportService = ref.read(exportServiceProvider);
      await exportService.exportAndShare(schedules);
    } on Exception catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败: $e')),
        );
      }
    }
  }
}
