# Lilt - 日程管理 App

跨平台日程管理应用，支持列表/甘特图/日历三种视图，基于 Flutter + Firebase 构建。

## 前置条件

- Flutter SDK >= 3.7.2
- Firebase 项目（需开启 Authentication 和 Cloud Firestore）

### 1. 安装 Flutter

参考 [Flutter 官方安装指南](https://docs.flutter.dev/get-started/install)

```bash
# 验证安装
flutter doctor
```

### 2. 创建 Firebase 项目并配置

1. 前往 [Firebase Console](https://console.firebase.google.com/) 创建项目
2. 启用 **Authentication** → 添加「电子邮件/密码」登录方式
3. 启用 **Cloud Firestore** → 创建数据库（选择生产模式或测试模式）

### 3. 安装依赖

```bash
flutter pub get
```

---

## 各平台启动方式

> **注意：** 首次部署到新平台前，需先执行 `flutterfire configure --platforms=<平台>` 注册应用到 Firebase。

---

### 开发环境

#### Web

```bash
flutter run -d chrome
```

> 启动后在 Chrome 浏览器中运行，支持热重载调试。

#### Windows

```bash
# 确保桌面开发环境已启用
flutter config --enable-windows-desktop
flutter run -d windows
```

#### Android

```bash
# 连接设备或启动模拟器后运行
flutter run -d android
```

#### iOS

```bash
# 安装 CocoaPods 依赖
cd ios && pod install && cd ..

# 连接设备或启动模拟器后运行
flutter run -d ios
```

> iOS 开发**必须**在 macOS 环境下进行。

---

### 生产环境

#### Web

```bash
# 构建生产版本
flutter build web
```

构建产物在 `build/web/` 目录，部署方式二选一：

**方式一：Firebase Hosting（推荐）**

```bash
# 1. 安装 Firebase CLI（首次）
npm install -g firebase-tools

# 2. 登录 Firebase 账号
firebase login

# 3. 初始化 Hosting（首次部署需执行）
firebase init hosting
#   提示选择项目 → 选择已有 Firebase 项目
#   公共目录输入：build/web
#   单页应用（SPA）重写：选择 Yes

# 4. 部署
firebase deploy --only hosting
```

> 部署后将获得 `https://<项目ID>.web.app` 访问地址。

**方式二：Vercel / Netlify 等静态托管**

将 `build/web/` 目录上传部署即可。注意需开启 SPA 重写规则（所有路由指向 `index.html`）。

#### Windows

```bash
flutter build windows
```

> 构建产物在 `build/windows/x64/runner/Release/` 目录。

#### Android

```bash
# 构建 APK
flutter build apk

# 或构建 App Bundle（推荐用于 Google Play）
flutter build appbundle
```

> APK 产物：`build/app/outputs/flutter-apk/app-release.apk`

#### iOS

```bash
# 构建 IPA（需在 macOS 上，配置好 Xcode 签名）
flutter build ios
```

> 构建产物在 `build/ios/iphoneos/Runner.app`。

---

## 项目结构

```
lib/
├── main.dart                    # 入口，Firebase 初始化（离线降级）
├── app.dart                     # App Widget + ProviderScope
├── core/
│   ├── constants/               # 分类、颜色常量
│   ├── env_config.dart          # 多环境配置
│   ├── providers.dart           # Riverpod 状态管理
│   ├── theme/                   # Material3 主题
│   └── utils/                   # 工具函数（日期/校验）
├── data/
│   ├── models/                  # 数据模型
│   ├── repositories/            # 数据仓库接口 + 实现
│   └── services/                # Firebase 认证 / 导出服务
├── features/
│   ├── auth/                    # 登录 / 注册
│   └── schedule/
│       ├── home_page.dart       # 主页 + 统计页 + 我的页
│       ├── detail/              # 新建 / 编辑日程
│       ├── list_view/           # 列表视图
│       ├── gantt_view/          # 甘特图视图
│       └── calendar_view/       # 日历视图
├── widgets/
│   └── common/                  # 通用组件（状态标签/空状态）
├── scripts/
│   └── build_windows.bat        # 一键构建脚本
├── docs/
│   ├── requirements.md          # 需求文档
│   ├── features.md              # 功能文档
│   └── framework.md             # 框架说明
└── analysis_options.yaml        # 代码规范（30+ lint 规则）
```

## 技术栈

| 层级 | 技术 |
|------|------|
| 前端框架 | Flutter |
| 后端服务 | Firebase (BaaS) |
| 认证 | Firebase Authentication |
| 数据库 | Cloud Firestore |
| 状态管理 | Riverpod |
| 文件导出 | share_plus + path_provider |
