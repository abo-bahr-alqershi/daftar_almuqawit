import 'package:firebase_auth/firebase_auth.dart';

import '../../errors/exceptions.dart';

/// خدمة المصادقة باستخدام Firebase
/// 
/// توفر عمليات تسجيل الدخول وإنشاء الحسابات
class FirebaseAuthService {
  FirebaseAuthService._();
  
  static final FirebaseAuthService _instance = FirebaseAuthService._();
  static FirebaseAuthService get instance => _instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ========== معلومات المستخدم ==========

  /// المستخدم الحالي
  User? get currentUser => _auth.currentUser;

  /// معرف المستخدم الحالي
  String? get currentUserId => _auth.currentUser?.uid;

  /// التحقق من تسجيل الدخول
  bool get isSignedIn => _auth.currentUser != null;

  /// مراقبة حالة المصادقة
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// مراقبة تغييرات المستخدم
  Stream<User?> get userChanges => _auth.userChanges();

  // ========== تسجيل الدخول ==========

  /// تسجيل الدخول بالبريد الإلكتروني وكلمة المرور
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code), code: e.code);
    } catch (e) {
      throw AuthException('فشل تسجيل الدخول: $e');
    }
  }

  /// تسجيل الدخول كضيف
  Future<UserCredential> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code), code: e.code);
    } catch (e) {
      throw AuthException('فشل تسجيل الدخول كضيف: $e');
    }
  }

  // ========== إنشاء الحساب ==========

  /// إنشاء حساب جديد
  Future<User?> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code), code: e.code);
    } catch (e) {
      throw AuthException('فشل إنشاء الحساب: $e');
    }
  }

  // ========== تسجيل الخروج ==========

  /// تسجيل الخروج
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code), code: e.code);
    } catch (e) {
      throw AuthException('فشل تسجيل الخروج: $e');
    }
  }

  // ========== إدارة كلمة المرور ==========

  /// إرسال رابط إعادة تعيين كلمة المرور
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code), code: e.code);
    } catch (e) {
      throw AuthException('فشل إرسال رابط إعادة التعيين: $e');
    }
  }

  /// تغيير كلمة المرور
  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code), code: e.code);
    } catch (e) {
      throw AuthException('فشل تغيير كلمة المرور: $e');
    }
  }

  // ========== إدارة الملف الشخصي ==========

  /// تحديث اسم العرض
  Future<void> updateDisplayName(String displayName) async {
    try {
      await _auth.currentUser?.updateDisplayName(displayName);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code), code: e.code);
    } catch (e) {
      throw AuthException('فشل تحديث الاسم: $e');
    }
  }

  /// تحديث البريد الإلكتروني
  Future<void> updateEmail(String email) async {
    try {
      await _auth.currentUser?.updateEmail(email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code), code: e.code);
    } catch (e) {
      throw AuthException('فشل تحديث البريد الإلكتروني: $e');
    }
  }

  /// تحديث الملف الشخصي
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      if (displayName != null) {
        await _auth.currentUser?.updateDisplayName(displayName);
      }
      if (photoURL != null) {
        await _auth.currentUser?.updatePhotoURL(photoURL);
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code), code: e.code);
    } catch (e) {
      throw AuthException('فشل تحديث الملف الشخصي: $e');
    }
  }

  /// حذف الحساب
  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code), code: e.code);
    } catch (e) {
      throw AuthException('فشل حذف الحساب: $e');
    }
  }

  /// إعادة تحميل بيانات المستخدم
  Future<void> reload() async {
    try {
      await _auth.currentUser?.reload();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code), code: e.code);
    } catch (e) {
      throw AuthException('فشل إعادة التحميل: $e');
    }
  }

  // ========== رسائل الأخطاء ==========

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'المستخدم غير موجود';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل';
      case 'weak-password':
        return 'كلمة المرور ضعيفة';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صحيح';
      case 'user-disabled':
        return 'تم تعطيل هذا الحساب';
      case 'too-many-requests':
        return 'محاولات كثيرة، حاول لاحقاً';
      case 'network-request-failed':
        return 'فشل الاتصال بالشبكة';
      case 'requires-recent-login':
        return 'يتطلب تسجيل دخول حديث';
      default:
        return 'خطأ في المصادقة';
    }
  }
}
