import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/schedule.dart';
import '../detail/schedule_detail_page.dart';

class CalendarViewPage extends StatefulWidget {
  final List<Schedule> schedules;

  const CalendarViewPage({super.key, required this.schedules});

  @override
  State<CalendarViewPage> createState() => _CalendarViewPageState();
}

class _CalendarViewPageState extends State<CalendarViewPage> {
  late DateTime _currentMonth;
  bool _isWeekView = false;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  List<Schedule> _schedulesForDay(DateTime day) {
    return widget.schedules.where((s) {
      return s.startTime.year == day.year &&
          s.startTime.month == day.month &&
          s.startTime.day == day.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _previousMonth,
              ),
              Expanded(
                child: Text(
                  DateFormat('yyyy年M月').format(_currentMonth),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _nextMonth,
              ),
              IconButton(
                icon: Icon(_isWeekView ? Icons.calendar_view_month : Icons.calendar_view_week),
                onPressed: () {
                  setState(() {
                    _isWeekView = !_isWeekView;
                  });
                },
              ),
            ],
          ),
        ),
        // Day headers
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: ['一', '二', '三', '四', '五', '六', '日'].map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const Divider(),
        // Calendar grid
        Expanded(child: _isWeekView ? _buildWeekView() : _buildMonthView()),
      ],
    );
  }

  Widget _buildMonthView() {
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstWeekday = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday;
    final totalCells = ((firstWeekday - 1 + daysInMonth) / 7).ceil() * 7;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        final dayOffset = index - (firstWeekday - 1);
        if (dayOffset < 0 || dayOffset >= daysInMonth) {
          return const SizedBox.shrink();
        }

        final day = dayOffset + 1;
        final date = DateTime(_currentMonth.year, _currentMonth.month, day);
        final daySchedules = _schedulesForDay(date);
        final isToday = date == todayDate;

        return GestureDetector(
          onTap: () {
            if (daySchedules.isNotEmpty) {
              _showDaySchedules(context, date, daySchedules);
            }
          },
          child: Container(
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: isToday
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const SizedBox(height: 2),
                Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isToday ? FontWeight.bold : null,
                    color: isToday
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                ),
                if (daySchedules.isNotEmpty)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        children: daySchedules.take(2).map((s) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 1),
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: AppConstants.parseColor(s.color),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text(
                              s.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeekView() {
    final today = DateTime.now();
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekDays = List.generate(7, (i) => weekStart.add(Duration(days: i)));

    return ListView.builder(
      itemCount: 7,
      itemBuilder: (context, index) {
        final date = weekDays[index];
        final daySchedules = _schedulesForDay(date);
        final dateFormat = DateFormat('MM/dd EEEE', 'zh_CN');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                dateFormat.format(date),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: date ==
                              DateTime(today.year, today.month, today.day)
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
              ),
            ),
            ...daySchedules.map((s) => ListTile(
                  dense: true,
                  leading: Container(
                    width: 4,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppConstants.parseColor(s.color),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  title: Text(s.title, style: const TextStyle(fontSize: 14)),
                  subtitle: Text(
                    '${DateFormat('HH:mm').format(s.startTime)} ~ ${DateFormat('HH:mm').format(s.endTime)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Text(s.status.label,
                      style: const TextStyle(fontSize: 12)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ScheduleDetailPage(schedule: s),
                      ),
                    );
                  },
                )),
            if (daySchedules.isEmpty)
              const Padding(
                padding: EdgeInsets.only(left: 16, bottom: 8),
                child: Text('无日程', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
            const Divider(height: 1),
          ],
        );
      },
    );
  }

  void _showDaySchedules(
    BuildContext context,
    DateTime date,
    List<Schedule> schedules,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                DateFormat('M月d日 EEEE', 'zh_CN').format(date),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ...schedules.map((s) => ListTile(
                  leading: Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppConstants.parseColor(s.color),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  title: Text(s.title),
                  subtitle: Text(
                    '${DateFormat('HH:mm').format(s.startTime)} ~ ${DateFormat('HH:mm').format(s.endTime)}',
                  ),
                  trailing: Text(s.status.label),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      this.context,
                      MaterialPageRoute(
                        builder: (_) => ScheduleDetailPage(schedule: s),
                      ),
                    );
                  },
                )),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}
