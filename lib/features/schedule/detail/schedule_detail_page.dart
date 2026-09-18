import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/providers.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/schedule.dart';

class ScheduleDetailPage extends ConsumerStatefulWidget {
  final Schedule? schedule;

  const ScheduleDetailPage({super.key, this.schedule});

  @override
  ConsumerState<ScheduleDetailPage> createState() => _ScheduleDetailPageState();
}

class _ScheduleDetailPageState extends ConsumerState<ScheduleDetailPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _startTime;
  late DateTime _endTime;
  late String _category;
  late String _color;
  late ScheduleStatus _status;
  bool _isSaving = false;

  bool get _isEditing => widget.schedule != null;

  @override
  void initState() {
    super.initState();
    final s = widget.schedule;
    _titleController = TextEditingController(text: s?.title ?? '');
    _descriptionController = TextEditingController(text: s?.description ?? '');
    _startTime = s?.startTime ?? DateTime.now().add(const Duration(hours: 1));
    _endTime = s?.endTime ?? DateTime.now().add(const Duration(hours: 2));
    _category = s?.category ?? AppConstants.defaultCategories.first;
    _color = s?.color ?? AppConstants.colorForCategory(_category);
    _status = s?.status ?? ScheduleStatus.pending;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) return;

      final scheduleRepo = ref.read(scheduleRepositoryProvider);

      final data = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'startTime': _startTime,
        'endTime': _endTime,
        'category': _category,
        'color': _color,
        'status': _status.apiValue,
        'updatedAt': DateTime.now(),
      };

      if (_isEditing) {
        await scheduleRepo.updateSchedule(
          user.uid,
          widget.schedule!.id,
          data,
        );
      } else {
        final schedule = Schedule(
          id: '',
          userId: user.uid,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          startTime: _startTime,
          endTime: _endTime,
          category: _category,
          color: _color,
          status: _status,
          createdAt: DateTime.now(),
        );
        await scheduleRepo.addSchedule(user.uid, schedule);
      }

      if (mounted) Navigator.pop(context);
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除日程'),
        content: Text('确定要删除「${_titleController.text}」吗？'),
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

    if (confirmed != true) return;

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) return;

      await ref
          .read(scheduleRepositoryProvider)
          .deleteSchedule(user.uid, widget.schedule!.id);
      if (mounted) Navigator.pop(context);
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('删除失败: $e')),
        );
      }
    }
  }

  void _cycleStatus() {
    setState(() {
      switch (_status) {
        case ScheduleStatus.pending:
          _status = ScheduleStatus.inProgress;
        case ScheduleStatus.inProgress:
          _status = ScheduleStatus.completed;
        case ScheduleStatus.completed:
          _status = ScheduleStatus.pending;
      }
    });
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final initial = isStart ? _startTime : _endTime;

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return;

    final newDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isStart) {
        _startTime = newDateTime;
      } else {
        _endTime = newDateTime;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '编辑日程' : '新建日程'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '标题',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入标题';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '描述',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            // Start time
            ListTile(
              leading: const Icon(Icons.play_arrow),
              title: const Text('开始时间'),
              subtitle: Text(
                '${dateFormat.format(_startTime)} ${timeFormat.format(_startTime)}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _pickDateTime(isStart: true),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // End time
            ListTile(
              leading: const Icon(Icons.stop),
              title: const Text('结束时间'),
              subtitle: Text(
                '${dateFormat.format(_endTime)} ${timeFormat.format(_endTime)}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _pickDateTime(isStart: false),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Category
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(
                labelText: '分类',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: AppConstants.defaultCategories.map((c) {
                return DropdownMenuItem(
                  value: c,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 6,
                        backgroundColor: AppConstants.parseColor(
                          AppConstants.colorForCategory(c),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(c),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _category = value;
                    _color = AppConstants.colorForCategory(value);
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            // Status
            Card(
              child: ListTile(
                leading: const Icon(Icons.flag),
                title: const Text('状态'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _statusChip(_status),
                    const SizedBox(width: 8),
                    const Icon(Icons.swap_horiz, size: 18),
                  ],
                ),
                onTap: _isEditing ? _cycleStatus : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Save button
            FilledButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_isEditing ? '保存修改' : '创建日程'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(ScheduleStatus status) {
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        status.label,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
    );
  }
}
