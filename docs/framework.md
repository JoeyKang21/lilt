# Lilt 项目框架说明

> 生成日期：2026-08-12 | 基于 docs/requirements.md + docs/features.md 完善

---

## 一、项目概述

基于 Flutter + Firebase 的跨平台日程管理应用。支持列表/甘特图/日历三种视图，数据通过 Cloud Firestore 实时同步，断网时离线可用。

---

## 二、核心技术栈

| 层级 | 技术 | 版本约束 |
|------|------|---------|
| 前端框架 | Flutter | SDK >= 3.7.2 |
| 后端服务 | Firebase (BaaS) | - |
| 认证 | Firebase Authentication | ^5.5.2 |
| 数据库 | Cloud Firestore | ^5.6.6（离线持久化） |
| 状态管理 | Riverpod | ^2.6.1 |
| 文件导出 | share_plus + path_provider | ^12.0.2 / ^2.1.5 |
| 国际化 | intl | ^0.19.0 |
| 代码规范 | flutter_lints | ^5.0.0（扩展了 30+ 条 lint 规则） |

---

## 三、项目目录结构

```
lilt/
├── lib/
│   ├── main.dart                            # 应用入口，Firebase 初始化
│   ├── app.dart                             # App Widget + ProviderScope
│   ├── core/
│   │   ├── constants/app_constants.dart     # 分类/颜色/集合名常量
│   │   ├── env_config.dart                  # 多环境配置 (dev/staging/prod)
│   │   ├── providers.dart                   # Riverpod 全局 Provider
│   │   ├── theme/app_theme.dart             # Material3 明暗主题
│   │   └── utils/helpers.dart               # 日期/校验/问候语工具函数
│   ├── data/
│   │   ├── models/schedule.dart             # Schedule 数据模型 + 状态枚举
│   │   ├── repositories/
│   │   │   ├── schedule_repository.dart     # 数据仓库接口（抽象层）
│   │   │   └── firestore_schedule_repository.dart  # Firestore 实现
│   │   └── services/
│   │       ├── auth_service.dart            # Firebase Auth 封装
│   │       ├── firestore_service.dart       # Firestore CRUD 服务（遗留）
│   │       └── export_service.dart          # TXT 导出 + 分享
│   ├── features/
│   │   ├── auth/auth_gate.dart              # 登录/注册/主入口路由
│   │   └── schedule/
│   │       ├── home_page.dart               # 主页+统计页+我的页（三 Tab）
│   │       ├── detail/schedule_detail_page.dart      # 新建/编辑/删除日程
│   │       ├── list_view/list_view_page.dart         # 列表视图（按天分组）
│   │       ├── gantt_view/gantt_view_page.dart       # 甘特图（日/周/月）
│   │       └── calendar_view/calendar_view_page.dart # 日历视图（月/周）
│   └── widgets/
│       └── common/
│           ├── status_chip.dart             # 通用状态标签
│           └── empty_state.dart             # 空状态占位组件
├── test/
│   └── widget_test.dart                     # 模型单元测试 + Widget 冒烟测试
├── scripts/
│   ├── build_windows.bat                    # Windows 构建脚本
│   └── build_platform.dart                  # 跨平台构建脚本
├── analysis_options.yaml                    # 代码规范（30+ lint 规则）
├── pubspec.yaml                             # 依赖管理
└── docs/
    ├── requirements.md                      # 需求文档
    └── features.md                          # 功能文档
```

---

## 四、本次完善内容

### 4.1 新增文件

| 文件 | 用途 | 对应文档要求 |
|------|------|-------------|
| `lib/app.dart` | 独立 App 入口 Widget | requirements.md §项目结构 |
| `lib/core/utils/helpers.dart` | 日期/校验/问候工具函数 | 消除重复代码 |
| `lib/core/env_config.dart` | 多环境配置 dev/staging/prod | 多环境适配 |
| `lib/data/repositories/schedule_repository.dart` | 数据仓库接口 | requirements.md §项目结构 |
| `lib/data/repositories/firestore_schedule_repository.dart` | Firestore 仓库实现 | 数据层抽象 |
| `lib/widgets/common/status_chip.dart` | 可复用的状态标签组件 | requirements.md §项目结构 |
| `lib/widgets/common/empty_state.dart` | 空状态占位组件 | UI 一致性 |
| `scripts/build_windows.bat` | Windows 一键构建脚本 | 部署流程 |
| `scripts/build_platform.dart` | 跨平台构建脚本 | 部署流程 |

### 4.2 重构/优化内容

| 文件 | 变更 |
|------|------|
| `analysis_options.yaml` | 从默认规则扩展为 30+ 条 lint 规则，涵盖代码风格/最佳实践/命名规范/错误处理/Flutter 特定 |
| `lib/main.dart` | Firebase 初始化增加 try-catch，离线模式静默降级；委托 `app.dart` 负责全局配置 |
| `pubspec.yaml` | `share_plus` 版本从 10.x 升级到 12.x（解决版本不兼容） |
| `lib/features/schedule/home_page.dart` | catch 语句加 `on Exception` 类型限定；const 声明优化 |
| `lib/features/schedule/detail/schedule_detail_page.dart` | 切换为 Repository 模式调用 |
| `lib/features/schedule/list_view/list_view_page.dart` | 切换为 Repository 模式调用；消除 unused import |
| `lib/features/auth/auth_gate.dart` | 移除未使用 import |

### 4.3 代码规范配置

`analysis_options.yaml` 扩展了以下 lint 规则组：

- **代码风格**：always_declare_return_types, prefer_const_constructors, prefer_single_quotes 等
- **最佳实践**：no_logic_in_create_state, use_build_context_synchronously 等
- **命名规范**：camel_case_types, file_names, constant_identifier_names 等
- **错误处理**：avoid_catches_without_on_clauses, avoid_void_async 等
- **Flutter 特定**：sized_box_for_whitespace, use_full_hex_values_for_flutter_colors 等

### 4.4 环境配置

`EnvConfig` 支持三种环境：

| 环境 | 对应构建模式 | 行为 |
|------|-------------|------|
| development | debug | Debug 日志 + 离线持久化 |
| staging | profile | 同 development |
| production | release | 无 Debug 日志 + 生产配置 |

---

## 五、构建与验证

### 5.1 本地验证结果

```bash
# 静态分析
flutter analyze     # → No issues found!

# 单元测试
flutter test        # → 7 tests passed
```

### 5.2 构建命令

```bash
# Web
flutter build web

# Windows
scripts\build_windows.bat        # 自动执行：pub get → analyze → test → build
# 或手动：
flutter build windows --release

# Android
flutter build apk

# iOS（仅 macOS）
flutter build ios
```

### 5.3 VS Code 调试

`.vscode/launch.json` 预置了 6 种调试配置：Windows (debug/release)、Chrome、Android、iOS、Run Tests。

---

## 六、架构设计要点

1. **Repository 模式**：`ScheduleRepository` 接口抽象数据访问，`FirestoreScheduleRepository` 为 Firestore 实现，后续可扩展本地 SQLite 实现。
2. **Provider 分层**：`authServiceProvider` → `currentUserProvider` → `schedulesProvider` → `filteredSchedulesProvider`，依赖链清晰。
3. **离线降级**：Firebase 初始化失败时静默进入离线模式，不阻塞 App 启动。
4. **多环境适配**：通过 `EnvConfig` 区分 dev/staging/prod 配置项。
