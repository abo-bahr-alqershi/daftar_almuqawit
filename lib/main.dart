import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/di/injection_container.dart';
import 'data/database/database_helper.dart';
import 'firebase_options.dart';

/// نقطة الدخول الرئيسية للتطبيق
/// 
/// يقوم بتهيئة:
/// - Firebase للخدمات السحابية
/// - قاعدة البيانات المحلية SQLite
/// - حقن التبعيات (Dependency Injection)
/// - معالجة الأخطاء على مستوى التطبيق
/// - إعدادات النظام الأساسية
Future<void> main() async {
  // تهيئة معالج الأخطاء العام
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('Flutter Error: ${details.exception}');
  };

  // معالجة الأخطاء خارج Flutter framework
  await runZonedGuarded(
    () async {
      // التأكد من تهيئة Flutter binding
      WidgetsFlutterBinding.ensureInitialized();

      // تعيين اتجاه الشاشة للوضع العمودي فقط
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      // تهيئة Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // تهيئة قاعدة البيانات المحلية
      await DatabaseHelper.init();

      // تهيئة حقن التبعيات
      await initDependencies();

      // تشغيل التطبيق
      runApp(const App());
    },
    (error, stackTrace) {
      debugPrint('Uncaught Error: $error');
      debugPrint('Stack Trace: $stackTrace');
    },
  );
}
