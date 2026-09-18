# 日程管理 App 需求文档

## 项目概述

一款跨平台日程管理应用，提供多种视图方式查看和管理日程，支持数据云端同步与本地导出。

---

## 技术栈

| 层级 | 技术选型 | 说明 |
|------|---------|------|
| 前端框架 | **Flutter** | 跨平台 UI 框架，一套代码同时覆盖 iOS、Android、Web、Desktop |
| 后端 / 数据服务 | **Firebase** | Google 提供的 BaaS 平台 |
| 认证 | Firebase Authentication | 邮箱账号创建与登录 |
| 数据库 | Cloud Firestore | 实时 NoSQL 文档数据库，支持离线持久化 |
| 本地存储 | Firestore Offline Persistence | 离线数据缓存与在线自动同步 |
| 状态管理 | Riverpod / Bloc | 推荐使用 Riverpod 进行状态管理 |

---

## 功能需求

### 1. 跨平台支持

| 平台 | 优先级 |
|------|--------|
| Android | P0 |
| iOS | P0 |
| Web | P1 |
| Windows | P1 |
| MacOS | P2 |

- 一套 Flutter 代码，多端运行，UI 自适应不同屏幕尺寸。
- 通过 Firebase 实现多设备数据实时同步，任意端修改后其他端秒级生效。

### 2. 用户认证

- 支持邮箱创建账号。
- 支持邮箱登录（含退出登录）。

### 3. 数据传输与同步

- 所有日程数据存储于 **Cloud Firestore**。
- 开启 **Firestore Offline Persistence**，无网络时仍可查看/编辑，联网后自动同步。
- 多设备间实时数据同步，冲突策略为 **最后写入获胜**。

#### Firestore 数据模型参考

```
users/{userId}
  ├── displayName: string
  ├── email: string
  └── createdAt: timestamp

schedules/{scheduleId}
  ├── userId: string (reference)
  ├── title: string
  ├── description: string
  ├── startTime: timestamp
  ├── endTime: timestamp
  ├── category: string
  ├── color: string
  ├── status: enum [pending, in_progress, completed]
  └── createdAt: timestamp
```

### 4. 日程视图

#### 4.1 列表视图

- 按时间顺序展示所有日程，支持分组（今天 / 明天 / 之后）。
- 每项显示标题、时间范围、状态标签。
- 支持下拉刷新、上拉加载更多。
- 支持按状态、分类筛选。
- 支持关键字搜索。

#### 4.2 甘特图视图

- 以时间轴形式展示日程，横轴为时间，纵轴为日程条目。
- 可视化展示日程的起止时间和重叠关系。
- 支持日/周/月三种时间粒度缩放。
- 支持横向滑动浏览时间范围。
- 点击条目可查看/编辑日程详情。

#### 4.3 日历视图

- 月视图 / 周视图，类似传统日历。
- 日期格内显示当日日程缩略。

### 5. 日程管理

- 创建日程：标题、描述、起止时间、分类、颜色标记。
- 编辑日程：修改任意字段，实时同步至 Firestore。
- 删除日程：滑动删除或长按删除，带确认弹窗。
- 状态流转：待办 → 进行中 → 已完成。

### 6. 导出功能

- 支持将当前筛选范围内的日程导出为 **TXT 文件**。
- 导出内容包含：标题、描述、起止时间、状态、分类。
- 导出格式示例：

```
==================== 日程列表 ====================
导出时间：2026-08-11 14:30

[1] 项目评审会议
    时间：2026-08-12 09:00 ~ 11:00
    状态：待办
    分类：工作
    描述：Q3 项目阶段性评审

[2] 健身训练
    时间：2026-08-12 18:00 ~ 19:30
    状态：待办
    分类：个人
    描述：-
====================================================
```

- 使用 `share_plus` / `file_saver` 插件实现文件分享与保存。

---

## 非功能需求

- **离线支持**：无网络环境下可正常查看和编辑日程。
- **实时同步**：网络恢复后秒级同步。
- **响应式**：适配手机、平板及桌面端布局。
- **性能**：日程列表支持虚拟滚动，甘特图渲染流畅。

---

## 推荐 Flutter 依赖

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.x
  cloud_firestore: ^5.x
  firebase_auth: ^5.x
  flutter_riverpod: ^2.x
  share_plus: ^10.x
  path_provider: ^2.x
  intl: ^0.19.x
```

---

## 项目结构（建议）

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── theme/
│   ├── utils/
│   └── constants/
├── data/
│   ├── models/
│   ├── repositories/
│   └── services/
├── features/
│   ├── auth/
│   ├── schedule/
│   │   ├── list_view/
│   │   ├── gantt_view/
│   │   └── detail/
│   └── export/
└── widgets/
    └── common/
```
