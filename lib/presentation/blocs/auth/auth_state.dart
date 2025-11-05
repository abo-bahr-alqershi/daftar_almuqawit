/// حالات Bloc المصادقة
/// تحتوي على جميع الحالات الممكنة للمصادقة

import 'package:equatable/equatable.dart';

/// الحالة الأساسية للمصادقة
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// الحالة الأولية
class AuthInitial extends AuthState {}

/// حالة جاري التحميل
class AuthLoading extends AuthState {}

/// حالة مصادقة ناجحة
class AuthAuthenticated extends AuthState {
  final String userId;
  final String userName;
  final String email;
  final String? phone;
  final String? photoUrl;
  
  AuthAuthenticated(
    this.userId,
    this.userName,
    this.email, {
    this.phone,
    this.photoUrl,
  });
  
  /// للتوافق مع الكود القديم
  String get userEmail => email;
  
  @override
  List<Object?> get props => [userId, userName, email, phone, photoUrl];
}

/// حالة غير مصادق
class AuthUnauthenticated extends AuthState {}

/// حالة تم إرسال رابط إعادة تعيين كلمة المرور
class AuthPasswordResetSent extends AuthState {
  final String email;
  
  AuthPasswordResetSent(this.email);
  
  @override
  List<Object?> get props => [email];
}

/// حالة خطأ في المصادقة
class AuthError extends AuthState {
  final String message;
  
  AuthError(this.message);
  
  @override
  List<Object?> get props => [message];
}
