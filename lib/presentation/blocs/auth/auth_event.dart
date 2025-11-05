/// أحداث Bloc المصادقة
/// تحتوي على جميع الأحداث المتعلقة بالمصادقة والتسجيل

/// الحدث الأساسي للمصادقة
abstract class AuthEvent {}

/// حدث تسجيل الدخول بالبريد وكلمة المرور
class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  final bool rememberMe;
  
  LoginEvent({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });
}

/// حدث تسجيل حساب جديد
class SignUpEvent extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String? phone;
  
  SignUpEvent({
    required this.email,
    required this.password,
    required this.name,
    this.phone,
  });
}

/// حدث تسجيل الخروج
class LogoutEvent extends AuthEvent {}

/// حدث التحقق من حالة المصادقة
class CheckAuthStatus extends AuthEvent {}

/// حدث استعادة كلمة المرور
class ForgotPasswordEvent extends AuthEvent {
  final String email;
  
  ForgotPasswordEvent(this.email);
}

/// حدث تحديث معلومات المستخدم
class UpdateUserInfoEvent extends AuthEvent {
  final String? name;
  final String? email;
  final String? phone;
  final String? photoUrl;
  
  UpdateUserInfoEvent({
    this.name,
    this.email,
    this.phone,
    this.photoUrl,
  });
}
