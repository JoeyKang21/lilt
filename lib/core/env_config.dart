/// 环境配置
/// 根据构建模式切换不同的环境参数
enum AppEnvironment {
  development,
  staging,
  production;

  /// 是否开发环境
  bool get isDevelopment => this == AppEnvironment.development;

  /// 是否生产环境
  bool get isProduction => this == AppEnvironment.production;
}

class EnvConfig {
  final AppEnvironment environment;

  const EnvConfig({required this.environment});

  /// 应用名称
  String get appName {
    switch (environment) {
      case AppEnvironment.development:
        return 'Lilt Dev';
      case AppEnvironment.staging:
        return 'Lilt Staging';
      case AppEnvironment.production:
        return 'Lilt';
    }
  }

  /// Firestore 数据是否启用离线持久化
  bool get enableFirestorePersistence => true;

  /// 是否启用调试日志
  bool get enableDebugLog => !environment.isProduction;

  /// 数据同步冲突策略
  String get conflictResolution => 'last_write_wins';

  /// 当前环境名称
  String get envName => environment.name;

  /// 从构建类型创建配置
  factory EnvConfig.fromBuildMode() {
    // 在 Flutter 中，通过 const 编译时常量区分环境
    // debug 模式 = development, profile = staging, release = production
    assert(() {
      // debug 模式下执行
      return true;
    }());
    return const EnvConfig(environment: AppEnvironment.development);
  }

  /// 生产环境配置（用于 release 构建）
  static const production = EnvConfig(
    environment: AppEnvironment.production,
  );

  /// 开发环境配置
  static const development = EnvConfig(
    environment: AppEnvironment.development,
  );
}
