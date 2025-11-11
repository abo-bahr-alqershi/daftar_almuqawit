import 'package:firebase_core/firebase_core.dart';
import '../../../firebase_options.dart';

/// خدمة Firebase الرئيسية
///
/// تقوم بتهيئة وإدارة اتصال Firebase
class FirebaseService {
  FirebaseService._();

  static final FirebaseService _instance = FirebaseService._();
  static FirebaseService get instance => _instance;

  bool _isInitialized = false;

  /// التحقق من حالة التهيئة
  bool get isInitialized => _isInitialized;

  /// تهيئة Firebase
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    try {
      // التحقق من أن Firebase تم تهيئته بالفعل في main.dart
      if (Firebase.apps.isNotEmpty) {
        _isInitialized = true;
        return;
      }

      // في حالة نادرة جداً: إذا لم يتم تهيئته في main
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _isInitialized = true;
    } catch (e) {
      // إذا كان Firebase مُهيّأ بالفعل، نتجاهل الخطأ
      if (e.toString().contains('duplicate-app') || Firebase.apps.isNotEmpty) {
        _isInitialized = true;
      } else {
        _isInitialized = false;
        rethrow;
      }
    }
  }

  /// إعادة تهيئة Firebase
  Future<void> reinitialize() async {
    _isInitialized = false;
    await initialize();
  }

  /// الحصول على تطبيق Firebase الحالي
  FirebaseApp get app {
    if (!_isInitialized) {
      throw StateError('Firebase لم يتم تهيئته بعد');
    }
    return Firebase.app();
  }

  /// التحقق من اتصال Firebase
  Future<bool> checkConnection() async {
    try {
      if (!_isInitialized) {
        return false;
      }
      // يمكن إضافة فحص إضافي هنا
      return true;
    } catch (e) {
      return false;
    }
  }
}
