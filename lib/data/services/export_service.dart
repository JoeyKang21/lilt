import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/schedule.dart';

class ExportService {
  Future<File> exportToTxt(List<Schedule> schedules) async {
    final now = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    final buffer = StringBuffer();

    buffer.writeln('==================== 日程列表 ====================');
    buffer.writeln('导出时间：$now');
    buffer.writeln();

    for (var i = 0; i < schedules.length; i++) {
      buffer.writeln('[${i + 1}] ${schedules[i].title}');
      final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
      buffer.writeln(
        '    时间：${dateFormat.format(schedules[i].startTime)} ~ ${dateFormat.format(schedules[i].endTime)}',
      );
      buffer.writeln('    状态：${schedules[i].status.label}');
      buffer.writeln('    分类：${schedules[i].category}');
      buffer.writeln(
        '    描述：${schedules[i].description.isEmpty ? '-' : schedules[i].description}',
      );
      buffer.writeln();
    }

    buffer.writeln('====================================================');

    final directory = await getTemporaryDirectory();
    final file = File(
      '${directory.path}/日程导出_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.txt',
    );
    await file.writeAsString(buffer.toString());
    return file;
  }

  Future<void> shareFile(File file) async {
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)]),
    );
  }

  Future<void> exportAndShare(List<Schedule> schedules) async {
    final file = await exportToTxt(schedules);
    await shareFile(file);
  }
}
