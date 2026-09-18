# Lilt 日程管理 - 后端服务部署说明

## 一、技术栈概述

| 层级 | 技术选型 | 版本 |
|------|---------|------|
| 数据库服务 | Cloud Firestore (NoSQL) | Firebase v13.x |
| 认证服务 | Firebase Authentication | Firebase v5.x |
| 安全规则 | Firestore Security Rules v2 | - |
| 索引优化 | Firestore Composite Indexes | - |
| 数据校验 | Flutter 端 ScheduleValidator | - |
| 测试框架 | Flutter Test | - |

## 二、Firebase 后端部署

### 2.1 前置条件

```bash
# 安装 Firebase CLI
npm install -g firebase-tools

# 登录 Firebase
firebase login

# 初始化 Firebase 项目
firebase init firestore
```

### 2.2 部署 Firestore 安全规则

```bash
# 部署安全规则和索引
firebase deploy --only firestore:rules,firestore:indexes
```

部署内容：
- `firestore.rules` - 数据库访问权限控制（用户隔离 + 字段校验）
- `firestore.indexes.json` - 复合索引配置（4 个索引优化查询性能）

### 2.3 Firestore 数据模型

```
users/{userId}           # 用户文档集合
  ├── email: string
  ├── displayName: string
  └── createdAt: timestamp
  └── schedules/{id}     # 用户的日程子集合
      ├── userId: string
      ├── title: string
      ├── description: string
      ├── startTime: timestamp
      ├── endTime: timestamp
      ├── category: string
      ├── color: string
      ├── status: enum[pending|in_progress|completed]
      └── createdAt: timestamp
```

### 2.4 安全规则要点

- 用户只能访问自己的文档（userId === request.auth.uid）
- 创建日程时校验完整数据结构
- 禁止跨用户读写
- 字段类型和值范围严格校验

## 三、Flutter 应用构建

### 3.1 构建前准备

```bash
# 获取依赖
flutter pub get

# 运行测试（全部通过后方可构建）
flutter test

# 代码分析
flutter analyze
```

### 3.2 平台构建命令

```bash
# Android (APK)
flutter build apk --release

# Android (AppBundle)
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release

# Windows
flutter build windows --release
```

### 3.3 环境配置

编辑 [lib/core/env_config.dart](file:///e:/KzWorkbench/KzLilt/lilt/lib/core/env_config.dart) 切换环境：

```dart
// 生产环境
static const production = EnvConfig(
  environment: AppEnvironment.production,
);
```

## 四、部署检查清单

- [ ] Firebase 项目已创建并配置
- [ ] Firestore 安全规则已部署
- [ ] Firestore 复合索引已创建
- [ ] Firebase Authentication 已启用邮箱登录
- [ ] 所有单元测试通过 (117/117)
- [ ] 代码分析无错误
- [ ] 平台构建产物已验证
