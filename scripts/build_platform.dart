# 构建 Lilt 支持的所有平台
# 用法: dart run scripts/build_platform.dart [--release]

import 'dart:io';

void main(List<String> args) async {
  final isRelease = args.contains('--release');
  final mode = isRelease ? 'release' : 'debug';

  print('========================================');
  print('  Lilt - 跨平台构建脚本');
  print('  模式: $mode');
  print('========================================');
  print('');

  final platforms = [
    if (Platform.isWindows) 'windows',
    if (Platform.isMacOS) 'macos',
    'web',
  ];

  for (final platform in platforms) {
    print('[BUILD] 开始构建 $platform ($mode)...');
    final result = await Process.run(
      'flutter',
      ['build', platform, if (isRelease) '--release'],
      runInShell: true,
    );

    if (result.exitCode == 0) {
      print('[OK] $platform 构建成功');
    } else {
      print('[FAIL] $platform 构建失败');
      print(result.stderr);
    }
  }

  print('');
  print('========================================');
  print('  构建完成');
  print('========================================');
}
