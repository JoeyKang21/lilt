import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/schedule.dart';
import '../detail/schedule_detail_page.dart';

class GanttViewPage extends StatefulWidget {
  final List<Schedule> schedules;

  const GanttViewPage({super.key, required this.schedules});

  @override
  State<GanttViewPage> createState() => _GanttViewPageState();
}

class _GanttViewPageState extends State<GanttViewPage> {
  late DateTime _viewStart;
  late DateTime _viewEnd;
  String _scale = 'day'; // day, week, month

  @override
  void initState() {
    super.initState();
    _viewStart = DateTime.now().subtract(const Duration(days: 1));
    _viewEnd = DateTime.now().add(const Duration(days: 7));
  }

  void _moveView(int days) {
    setState(() {
      _viewStart = _viewStart.add(Duration(days: days));
      _viewEnd = _viewEnd.add(Duration(days: days));
    });
  }

  void _changeScale(String scale) {
    setState(() {
      _scale = scale;
      switch (scale) {
        case 'day':
          _viewEnd = _viewStart.add(const Duration(days: 7));
        case 'week':
          _viewEnd = _viewStart.add(const Duration(days: 28));
        case 'month':
          _viewEnd = _viewStart.add(const Duration(days: 90));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final visibleSchedules = widget.schedules.where((s) {
      return s.startTime.isBefore(_viewEnd) && s.endTime.isAfter(_viewStart);
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    if (widget.schedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.view_timeline,
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

    final totalDays = _viewEnd.difference(_viewStart).inDays;
    final cellWidth = totalDays > 7 ? 40.0 : 60.0;
    final totalWidth = cellWidth * totalDays;
    const rowHeight = 56.0;

    return Column(
      children: [
        // Controls
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  final step = _scale == 'month' ? 30 : _scale == 'week' ? 7 : 3;
                  _moveView(-step);
                },
              ),
              Expanded(
                child: Text(
                  '${DateFormat('MM/dd').format(_viewStart)} - ${DateFormat('MM/dd').format(_viewEnd)}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  final step = _scale == 'month' ? 30 : _scale == 'week' ? 7 : 3;
                  _moveView(step);
                },
              ),
            ],
          ),
        ),
        // Scale buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: ['day', 'week', 'month'].map((scale) {
            final labels = {'day': '日', 'week': '周', 'month': '月'};
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text(labels[scale]!),
                selected: _scale == scale,
                onSelected: (_) => _changeScale(scale),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        // Gantt chart
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: totalWidth + 120,
              child: Column(
                children: [
                  // Date headers
                  SizedBox(
                    height: 30,
                    child: Row(
                      children: [
                        const SizedBox(width: 120),
                        ...List.generate(totalDays, (i) {
                          final date = _viewStart.add(Duration(days: i));
                          return SizedBox(
                            width: cellWidth,
                            child: Center(
                              child: Text(
                                DateFormat('MM/dd').format(date),
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Schedule rows
                  Expanded(
                    child: ListView.builder(
                      itemCount: visibleSchedules.length,
                      itemBuilder: (context, index) {
                        final schedule = visibleSchedules[index];
                        final startOffset = schedule.startTime
                                .difference(_viewStart)
                                .inDays
                                .toDouble() +
                            schedule.startTime.hour / 24.0;
                        final duration = schedule.endTime
                                .difference(schedule.startTime)
                                .inMinutes /
                            (24 * 60).toDouble();
                        final barLeft = startOffset * cellWidth;
                        final barWidth = (duration * cellWidth).clamp(
                          cellWidth * 0.5,
                          double.infinity,
                        );

                        return SizedBox(
                          height: rowHeight,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 120,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        schedule.title,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context).textTheme.labelSmall,
                                      ),
                                      Text(
                                        schedule.status.label,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: barLeft,
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  ScheduleDetailPage(schedule: schedule),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          height: rowHeight - 8,
                                          width: barWidth.clamp(4, totalWidth),
                                          margin: const EdgeInsets.symmetric(vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppConstants.parseColor(schedule.color),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          alignment: Alignment.centerLeft,
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          child: Text(
                                            schedule.title,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
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
