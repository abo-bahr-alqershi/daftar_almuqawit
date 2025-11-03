import 'dart:io';

import 'package:firebase_core/firebase_core.dart' as firebase;

import 'exceptions.dart';
import 'failures.dart';

/// معالج الأخطاء المركزي
/// 
/// يقوم بتحويل الاستثناءات إلى فشل (Failures) يمكن التعامل معه
/// في طبقة Domain والـ Presentation
class ErrorHandler {
  ErrorHandler._();

  /// تحويل استثناء إلى فشل
  static Failure handleException(Object error, [StackTrace? stackTrace]) {
    // طباعة الخطأ للتطوير
    _logError(error, stackTrace);

    // تحويل الاستثناءات المخصصة
    if (error is AppException) {
      return _handleAppException(error);
    }

    // تحويل استثناءات Firebase
    if (error is firebase.FirebaseException) {
      return _handleFirebaseException(error);
    }

    // تحويل استثناءات النظام
    if (error is SocketException) {
      return const NoInternetFailure();
    }

    if (error is TimeoutException) {
      return const TimeoutFailure();
    }

    if (error is FormatException) {
      return const InvalidDataFailure('تنسيق البيانات غير صحيح');
    }

    // خطأ غير معروف
    return UnknownFailure(_getErrorMessage(error));
  }

  /// معالجة استثناءات التطبيق المخصصة
  static Failure _handleAppException(AppException exception) {
    if (exception is DatabaseException) {
      return DatabaseFailure(exception.message, code: exception.code);
    }

    if (exception is NetworkException) {
      if (exception is NoInternetException) {
        return const NoInternetFailure();
      }
      if (exception is TimeoutException) {
        return const TimeoutFailure();
      }
      if (exception is ServerException) {
        return ServerFailure(exception.message);
      }
      return NetworkFailure(exception.message, code: exception.code);
    }

    if (exception is FirebaseException) {
      if (exception is AuthException) {
        return AuthFailure(exception.message, code: exception.code);
      }
      if (exception is FirestoreException) {
        return FirestoreFailure(exception.message, code: exception.code);
      }
      if (exception is StorageException) {
        return StorageFailure(exception.message, code: exception.code);
      }
      return FirebaseFailure(exception.message, code: exception.code);
    }

    if (exception is CacheException) {
      if (exception is CacheNotFoundException) {
        return const CacheNotFoundFailure();
      }
      return CacheFailure(exception.message);
    }

    if (exception is ValidationException) {
      return ValidationFailure(exception.message);
    }

    if (exception is PermissionException) {
      if (exception is PermissionDeniedException) {
        return const PermissionDeniedFailure();
      }
      return PermissionFailure(exception.message);
    }

    if (exception is SyncException) {
      if (exception is ConflictException) {
        return const ConflictFailure();
      }
      return SyncFailure(exception.message, code: exception.code);
    }

    if (exception is NotFoundException) {
      return NotFoundFailure(exception.message);
    }

    if (exception is NotImplementedException) {
      return NotImplementedFailure(exception.message);
    }

    return UnknownFailure(exception.message);
  }

  /// معالجة استثناءات Firebase
  static Failure _handleFirebaseException(firebase.FirebaseException exception) {
    final code = exception.code;
    final message = exception.message ?? 'حدث خطأ في Firebase';

    // أخطاء المصادقة
    if (code.startsWith('auth/')) {
      return AuthFailure(_getAuthErrorMessage(code), code: code);
    }

    // أخطاء Firestore
    if (code.startsWith('firestore/')) {
      return FirestoreFailure(message, code: code);
    }

    // أخطاء Storage
    if (code.startsWith('storage/')) {
      return StorageFailure(message, code: code);
    }

    return FirebaseFailure(message, code: code);
  }

  /// الحصول على رسالة خطأ المصادقة بالعربية
  static String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'auth/user-not-found':
        return 'المستخدم غير موجود';
      case 'auth/wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'auth/email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل';
      case 'auth/weak-password':
        return 'كلمة المرور ضعيفة';
      case 'auth/invalid-email':
        return 'البريد الإلكتروني غير صحيح';
      case 'auth/user-disabled':
        return 'تم تعطيل هذا الحساب';
      case 'auth/too-many-requests':
        return 'محاولات كثيرة، حاول لاحقاً';
      case 'auth/network-request-failed':
        return 'فشل الاتصال بالشبكة';
      default:
        return 'خطأ في المصادقة';
    }
  }

  /// الحصول على رسالة الخطأ من الكائن
  static String _getErrorMessage(Object error) {
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return error.toString();
  }

  /// تسجيل الخطأ (للتطوير)
  static void _logError(Object error, [StackTrace? stackTrace]) {
    // يمكن استخدام خدمة تسجيل متقدمة هنا
    // مثل Firebase Crashlytics أو Sentry
    // ignore: avoid_print
    print('❌ Error: $error');
    if (stackTrace != null) {
      // ignore: avoid_print
      print('Stack Trace: $stackTrace');
    }
  }

  /// تحويل الفشل إلى رسالة قابلة للعرض للمستخدم
  static String getDisplayMessage(Failure failure) {
    return failure.message;
  }

  /// التحقق من نوع الفشل
  static bool isNetworkFailure(Failure failure) {
    return failure is NetworkFailure;
  }

  static bool isDatabaseFailure(Failure failure) {
    return failure is DatabaseFailure;
  }

  static bool isAuthFailure(Failure failure) {
    return failure is AuthFailure;
  }

  static bool isCacheFailure(Failure failure) {
    return failure is CacheFailure;
  }

  static bool isValidationFailure(Failure failure) {
    return failure is ValidationFailure;
  }
}
