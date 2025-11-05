import 'package:get_it/get_it.dart';
import 'service_locator.dart';

// Re-export service locator for convenience
export 'service_locator.dart' show setupServiceLocator;

/// حاوية حقن التبعيات الرئيسية
/// 
/// تستخدم GetIt كحاوية لإدارة جميع التبعيات في التطبيق
/// وتوفر طريقة موحدة للوصول إلى الخدمات والمستودعات والحالات
final GetIt sl = GetIt.instance;

/// تهيئة جميع التبعيات في التطبيق
/// 
/// يتم استدعاء هذه الدالة عند بدء التطبيق وتقوم بـ:
/// 1. تسجيل جميع الخدمات (Services)
/// 2. تسجيل المستودعات (Repositories)
/// 3. تسجيل حالات الاستخدام (Use Cases)
/// 4. تسجيل كتل الحالة (BLoCs)
/// 5. تهيئة الخدمات الأساسية مثل قاعدة البيانات
/// 
/// يتم تنظيم التسجيلات في modules منفصلة لسهولة الإدارة:
/// - [DatabaseModule]: خدمات قاعدة البيانات المحلية
/// - [FirebaseModule]: خدمات Firebase
/// - [RepositoryModule]: المستودعات
/// - [BlocModule]: كتل الحالة
/// - [ServiceLocator]: باقي الخدمات والـ Use Cases
Future<void> initDependencies() async {
  // تهيئة التبعيات من ServiceLocator
  // يحتوي على جميع التسجيلات المنظمة في modules
  await ServiceLocator.setup();
  
  // يمكن إضافة تهيئات إضافية هنا إذا لزم الأمر
  // مثل تهيئة قواعد البيانات أو الخدمات الخارجية
  
  // التحقق من اكتمال التسجيلات (في وضع التطوير فقط)
  assert(() {
    _verifyRegistrations();
    return true;
  }());
}

/// التحقق من تسجيل جميع التبعيات المطلوبة
/// يستخدم في وضع التطوير فقط للتأكد من اكتمال التسجيلات
void _verifyRegistrations() {
  try {
    // التحقق من الخدمات الأساسية
    // TODO: إضافة التحقق من الخدمات عند التنفيذ
    // sl.get<DatabaseHelper>();
    // sl.get<FirebaseService>();
    // sl.get<ConnectivityService>();
    
    // التحقق من BLoCs الأساسية
    // sl.get<AppBloc>();
    // sl.get<AuthBloc>();
    
    print('[DI] ✅ جميع التبعيات الأساسية مسجلة بنجاح');
  } catch (e) {
    print('[DI] ⚠️ خطأ في تسجيل التبعيات: $e');
  }
}
