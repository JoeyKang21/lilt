import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/providers.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/schedule.dart';
import '../detail/schedule_detail_page.dart';

class ScheduleListView extends ConsumerWidget {
  final List<Schedule> schedules;

  const ScheduleListView({super.key, required this.schedules});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (schedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              '暂无日程',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
    }

    // Group schedules
    final grouped = <String, List<Schedule>>{};
    for (final s in schedules) {
      grouped.putIfAbsent(s.dateGroupLabel, () => []).add(s);
    }

    final order = ['今天', '明天', '之后'];
    final sortedGroups = order.where((key) => grouped.containsKey(key));

    return ListView.builder(
      itemCount: sortedGroups.length,
      itemBuilder: (context, index) {
        final label = sortedGroups.elementAt(index);
        final items = grouped[label]!;
        return _ScheduleGroup(
          label: label,
          schedules: items,
        );
      },
    );
  }
}

class _ScheduleGroup extends StatelessWidget {
  final String label;
  final List<Schedule> schedules;

  const _ScheduleGroup({
    required this.label,
    required this.schedules,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ...schedules.map((schedule) => _ScheduleCard(schedule: schedule)),
      ],
    );
  }
}

class _ScheduleCard extends ConsumerWidget {
  final Schedule schedule;

  const _ScheduleCard({required this.schedule});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('MM/dd');

    return Dismissible(
      key: Key(schedule.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('删除日程'),
            content: Text('确定要删除「${schedule.title}」吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('删除', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        final scheduleRepo = ref.read(scheduleRepositoryProvider);
        final user = ref.read(currentUserProvider);
        if (user != null) {
          scheduleRepo.deleteSchedule(user.uid, schedule.id);
        }
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ScheduleDetailPage(schedule: schedule),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppConstants.parseColor(schedule.color),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        schedule.title,
                        style: Theme.of(context).textTheme.titleSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${dateFormat.format(schedule.startTime)} ${timeFormat.format(schedule.startTime)} ~ ${timeFormat.format(schedule.endTime)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    _StatusChip(status: schedule.status),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppConstants.parseColor(schedule.color)
                            .withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        schedule.category,
                        style: TextStyle(
                          fontSize: 10,
                          color: AppConstants.parseColor(schedule.color),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
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
        style: TextStyle(fontSize: 11, color: color),
      ),
    );
  }
}
