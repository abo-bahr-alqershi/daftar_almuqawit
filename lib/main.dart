import 'package:flutter/material.dart';
import 'app.dart';
import 'data/database/database_helper.dart';
import 'core/di/service_locator.dart';
import 'package:firebase_core/firebase_core.dart';

/// نقطة الدخول للتطبيق: تشغيل عنصر App الرئيسي
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await DatabaseHelper.init();
  await ServiceLocator.setup();
  runApp(const App());
}
