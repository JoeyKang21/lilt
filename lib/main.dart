import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 初始化（需 flutterfire configure 先配置）
  // 如未配置 Firebase，注释掉下面两行并直接运行 AppWithProviders
  try {
    await Firebase.initializeApp();

    // 启用 Firestore 离线持久化（需求文档明确要求）
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } on Exception catch (_) {
    // Firebase 未配置时静默失败，App 将以离线模式运行
    debugPrint('[Lilt] Firebase not configured, running in offline mode');
  }

  runApp(const AppWithProviders());
}
