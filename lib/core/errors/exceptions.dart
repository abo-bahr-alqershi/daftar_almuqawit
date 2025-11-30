/// استثناءات مخصصة للتطبيق
///
/// يحتوي على جميع أنواع الاستثناءات المستخدمة في طبقة البيانات
abstract class AppException implements Exception {
  const AppException(this.message, {this.cause, this.code});

  /// رسالة الخطأ
  final String message;

  /// السبب الأصلي للخطأ
  final Object? cause;

  /// كود الخطأ
  final String? code;

  @override
  String toString() =>
      'AppException: $message${code != null ? ' (Code: $code)' : ''}';
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
  const DatabaseCreationException([super.message = 'فشل إنشاء قاعدة البيانات']);
}

/// استثناء عند فشل الترحيل
class DatabaseMigrationException extends DatabaseException {
  const DatabaseMigrationException([
    super.message = 'فشل ترحيل قاعدة البيانات',
  ]);
}

/// استثناء عند فشل الاستعلام
class DatabaseQueryException extends DatabaseException {
  const DatabaseQueryException([super.message = 'فشل تنفيذ الاستعلام']);
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
  const NoInternetException([super.message = 'لا يوجد اتصال بالإنترنت']);
}

/// استثناء انتهاء مهلة الاتصال
class TimeoutException extends NetworkException {
  const TimeoutException([super.message = 'انتهت مهلة الاتصال']);
}

/// استثناء خطأ في الخادم
class ServerException extends NetworkException {
  const ServerException([super.message = 'خطأ في الخادم']);
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
  const AuthException(super.message, {super.code});
}

/// استثناء Firestore
class FirestoreException extends FirebaseException {
  const FirestoreException(super.message, {super.code});
}

/// استثناء Firebase Storage
class StorageException extends FirebaseException {
  const StorageException(super.message, {super.code});
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
  const CacheNotFoundException([super.message = 'لا توجد بيانات مخزنة']);
}

/// استثناء انتهاء صلاحية البيانات المخزنة
class CacheExpiredException extends CacheException {
  const CacheExpiredException([
    super.message = 'انتهت صلاحية البيانات المخزنة',
  ]);
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
  const InvalidDataException([super.message = 'البيانات غير صالحة']);
}

/// استثناء حقل مطلوب
class RequiredFieldException extends ValidationException {
  const RequiredFieldException(this.fieldName)
    : super('الحقل "$fieldName" مطلوب');

  final String fieldName;
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
  const PermissionDeniedException([super.message = 'تم رفض الصلاحية']);
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
  const ConflictException([super.message = 'تعارض في البيانات']);
}

/// استثناء فشل المزامنة
class SyncFailedException extends SyncException {
  const SyncFailedException([super.message = 'فشلت عملية المزامنة']);
}

// ========== استثناءات عامة ==========

/// استثناء غير متوقع
class UnexpectedException extends AppException {
  const UnexpectedException([super.message = 'حدث خطأ غير متوقع']);
}

/// استثناء غير مطبق
class NotImplementedException extends AppException {
  const NotImplementedException([super.message = 'هذه الميزة غير مطبقة بعد']);
}

/// استثناء عنصر غير موجود
class NotFoundException extends AppException {
  const NotFoundException([super.message = 'العنصر غير موجود']);
}
