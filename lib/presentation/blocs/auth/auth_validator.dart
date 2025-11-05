// ignore_for_file: public_member_api_docs

/// مدقق البيانات للمصادقة
class AuthValidator {
  /// التحقق من صحة رقم الهاتف
  static bool isValidPhone(String? phone) => (phone ?? '').length >= 6;
  
  /// التحقق من صحة البريد الإلكتروني
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    return emailRegex.hasMatch(email);
  }
  
  /// التحقق من قوة كلمة المرور
  static bool isStrongPassword(String password) {
    if (password.isEmpty) return false;
    
    // على الأقل 6 أحرف
    if (password.length < 6) return false;
    
    return true;
  }
  
  /// التحقق من تطابق كلمات المرور
  static bool passwordsMatch(String password, String confirmPassword) {
    return password == confirmPassword;
  }
  
  /// التحقق من صحة الاسم
  static bool isValidName(String name) {
    return name.trim().isNotEmpty && name.trim().length >= 2;
  }
}
