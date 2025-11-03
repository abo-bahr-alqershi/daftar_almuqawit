/// استثناءات مخصصة للتطبيق
/// 
/// يحتوي على جميع أنواع الاستثناءات المستخدمة في طبقة البيانات
abstract class AppException implements Exception {
  /// رسالة الخطأ
  final String message;
  
  /// السبب الأصلي للخطأ
  final Object? cause;
  
  /// كود الخطأ
  final String? code;

  const AppException(this.message, {this.cause, this.code});

  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

// ========== استثناءات قاعدة البيانات ==========

/// استثناء قاعدة البيانات المحلية
class DatabaseException extends AppException {
  const DatabaseException(super.message, {super.cause, super.code});

  @override
  String toString() => 'DatabaseException: $message';
}

/// استثناء عند فشل إنشاء قاعدة البيانات
class DatabaseCreationException extends DatabaseException {
  const DatabaseCreationException([String message = 'فشل إنشاء قاعدة البيانات'])
      : super(message);
}

/// استثناء عند فشل الترحيل
class DatabaseMigrationException extends DatabaseException {
  const DatabaseMigrationException([String message = 'فشل ترحيل قاعدة البيانات'])
      : super(message);
}

/// استثناء عند فشل الاستعلام
class DatabaseQueryException extends DatabaseException {
  const DatabaseQueryException([String message = 'فشل تنفيذ الاستعلام'])
      : super(message);
}

// ========== استثناءات الشبكة ==========

/// استثناء الشبكة
class NetworkException extends AppException {
  const NetworkException(super.message, {super.cause, super.code});

  @override
  String toString() => 'NetworkException: $message';
}

/// استثناء عدم وجود اتصال بالإنترنت
class NoInternetException extends NetworkException {
  const NoInternetException([String message = 'لا يوجد اتصال بالإنترنت'])
      : super(message);
}

/// استثناء انتهاء مهلة الاتصال
class TimeoutException extends NetworkException {
  const TimeoutException([String message = 'انتهت مهلة الاتصال'])
      : super(message);
}

/// استثناء خطأ في الخادم
class ServerException extends NetworkException {
  const ServerException([String message = 'خطأ في الخادم'])
      : super(message);
}

// ========== استثناءات Firebase ==========

/// استثناء Firebase
class FirebaseException extends AppException {
  const FirebaseException(super.message, {super.cause, super.code});

  @override
  String toString() => 'FirebaseException: $message';
}

/// استثناء المصادقة
class AuthException extends FirebaseException {
  const AuthException(super.message, {super.code}) : super();
}

/// استثناء Firestore
class FirestoreException extends FirebaseException {
  const FirestoreException(super.message, {super.code}) : super();
}

/// استثناء Firebase Storage
class StorageException extends FirebaseException {
  const StorageException(super.message, {super.code}) : super();
}

// ========== استثناءات التخزين المحلي ==========

/// استثناء التخزين المحلي
class CacheException extends AppException {
  const CacheException(super.message, {super.cause});

  @override
  String toString() => 'CacheException: $message';
}

/// استثناء عدم وجود بيانات مخزنة
class CacheNotFoundException extends CacheException {
  const CacheNotFoundException([String message = 'لا توجد بيانات مخزنة'])
      : super(message);
}

/// استثناء انتهاء صلاحية البيانات المخزنة
class CacheExpiredException extends CacheException {
  const CacheExpiredException([String message = 'انتهت صلاحية البيانات المخزنة'])
      : super(message);
}

// ========== استثناءات التحقق من الصحة ==========

/// استثناء التحقق من الصحة
class ValidationException extends AppException {
  const ValidationException(super.message, {super.cause});

  @override
  String toString() => 'ValidationException: $message';
}

/// استثناء بيانات غير صالحة
class InvalidDataException extends ValidationException {
  const InvalidDataException([String message = 'البيانات غير صالحة'])
      : super(message);
}

/// استثناء حقل مطلوب
class RequiredFieldException extends ValidationException {
  final String fieldName;
  
  const RequiredFieldException(this.fieldName)
      : super('الحقل "$fieldName" مطلوب');
}

// ========== استثناءات الصلاحيات ==========

/// استثناء الصلاحيات
class PermissionException extends AppException {
  const PermissionException(super.message, {super.cause});

  @override
  String toString() => 'PermissionException: $message';
}

/// استثناء رفض الصلاحية
class PermissionDeniedException extends PermissionException {
  const PermissionDeniedException([String message = 'تم رفض الصلاحية'])
      : super(message);
}

// ========== استثناءات المزامنة ==========

/// استثناء المزامنة
class SyncException extends AppException {
  const SyncException(super.message, {super.cause, super.code});

  @override
  String toString() => 'SyncException: $message';
}

/// استثناء تعارض البيانات
class ConflictException extends SyncException {
  const ConflictException([String message = 'تعارض في البيانات'])
      : super(message);
}

/// استثناء فشل المزامنة
class SyncFailedException extends SyncException {
  const SyncFailedException([String message = 'فشلت عملية المزامنة'])
      : super(message);
}

// ========== استثناءات عامة ==========

/// استثناء غير متوقع
class UnexpectedException extends AppException {
  const UnexpectedException([String message = 'حدث خطأ غير متوقع'])
      : super(message);
}

/// استثناء غير مطبق
class NotImplementedException extends AppException {
  const NotImplementedException([String message = 'هذه الميزة غير مطبقة بعد'])
      : super(message);
}

/// استثناء عنصر غير موجود
class NotFoundException extends AppException {
  const NotFoundException([String message = 'العنصر غير موجود'])
      : super(message);
}
