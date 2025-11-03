/// أنواع الفشل في العمليات
/// 
/// يتم استخدامها في طبقة Domain والـ Presentation
/// لتمثيل نتائج العمليات الفاشلة بشكل آمن
sealed class Failure {
  /// رسالة الفشل
  final String message;
  
  /// كود الخطأ (اختياري)
  final String? code;

  const Failure(this.message, {this.code});

  @override
  String toString() => 'Failure: $message${code != null ? ' (Code: $code)' : ''}';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure && 
           other.message == message && 
           other.code == code;
  }
  
  @override
  int get hashCode => message.hashCode ^ code.hashCode;
}

// ========== فشل قاعدة البيانات ==========

/// فشل في عمليات قاعدة البيانات المحلية
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, {super.code});

  @override
  String toString() => 'DatabaseFailure: $message';
}

// ========== فشل الشبكة ==========

/// فشل في عمليات الشبكة
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});

  @override
  String toString() => 'NetworkFailure: $message';
}

/// فشل بسبب عدم وجود اتصال بالإنترنت
class NoInternetFailure extends NetworkFailure {
  const NoInternetFailure([String message = 'لا يوجد اتصال بالإنترنت'])
      : super(message);
}

/// فشل بسبب انتهاء المهلة
class TimeoutFailure extends NetworkFailure {
  const TimeoutFailure([String message = 'انتهت مهلة الاتصال'])
      : super(message);
}

/// فشل بسبب خطأ في الخادم
class ServerFailure extends NetworkFailure {
  const ServerFailure([String message = 'خطأ في الخادم'])
      : super(message);
}

// ========== فشل Firebase ==========

/// فشل في عمليات Firebase
class FirebaseFailure extends Failure {
  const FirebaseFailure(super.message, {super.code});

  @override
  String toString() => 'FirebaseFailure: $message';
}

/// فشل في المصادقة
class AuthFailure extends FirebaseFailure {
  const AuthFailure(super.message, {super.code});

  @override
  String toString() => 'AuthFailure: $message';
}

/// فشل في Firestore
class FirestoreFailure extends FirebaseFailure {
  const FirestoreFailure(super.message, {super.code});

  @override
  String toString() => 'FirestoreFailure: $message';
}

/// فشل في Firebase Storage
class StorageFailure extends FirebaseFailure {
  const StorageFailure(super.message, {super.code});

  @override
  String toString() => 'StorageFailure: $message';
}

// ========== فشل التخزين المؤقت ==========

/// فشل في عمليات التخزين المؤقت
class CacheFailure extends Failure {
  const CacheFailure(super.message);

  @override
  String toString() => 'CacheFailure: $message';
}

/// فشل بسبب عدم وجود بيانات مخزنة
class CacheNotFoundFailure extends CacheFailure {
  const CacheNotFoundFailure([String message = 'لا توجد بيانات مخزنة'])
      : super(message);
}

// ========== فشل التحقق من الصحة ==========

/// فشل في التحقق من صحة البيانات
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);

  @override
  String toString() => 'ValidationFailure: $message';
}

/// فشل بسبب بيانات غير صالحة
class InvalidDataFailure extends ValidationFailure {
  const InvalidDataFailure([String message = 'البيانات غير صالحة'])
      : super(message);
}

// ========== فشل الصلاحيات ==========

/// فشل بسبب الصلاحيات
class PermissionFailure extends Failure {
  const PermissionFailure(super.message);

  @override
  String toString() => 'PermissionFailure: $message';
}

/// فشل بسبب رفض الصلاحية
class PermissionDeniedFailure extends PermissionFailure {
  const PermissionDeniedFailure([String message = 'تم رفض الصلاحية'])
      : super(message);
}

// ========== فشل المزامنة ==========

/// فشل في عمليات المزامنة
class SyncFailure extends Failure {
  const SyncFailure(super.message, {super.code});

  @override
  String toString() => 'SyncFailure: $message';
}

/// فشل بسبب تعارض البيانات
class ConflictFailure extends SyncFailure {
  const ConflictFailure([String message = 'تعارض في البيانات'])
      : super(message);
}

// ========== فشل عام ==========

/// فشل غير متوقع
class UnknownFailure extends Failure {
  const UnknownFailure([String message = 'حدث خطأ غير متوقع'])
      : super(message);
}

/// فشل بسبب ميزة غير مطبقة
class NotImplementedFailure extends Failure {
  const NotImplementedFailure([String message = 'هذه الميزة غير مطبقة بعد'])
      : super(message);
}

/// فشل بسبب عنصر غير موجود
class NotFoundFailure extends Failure {
  const NotFoundFailure([String message = 'العنصر غير موجود'])
      : super(message);
}
