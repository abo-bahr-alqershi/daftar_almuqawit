/// أدوات التحقق من صحة المُدخلات
/// 
/// يوفر مجموعة شاملة من دوال التحقق من صحة البيانات
class Validators {
  Validators._();

  // ========== التحقق الأساسي ==========

  /// التحقق من أن الحقل مطلوب
  static String? required(String? value, {String field = 'الحقل'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field مطلوب';
    }
    return null;
  }

  /// التحقق من الحد الأدنى للطول
  static String? minLength(
    String? value,
    int minLength, {
    String field = 'الحقل',
  }) {
    if (value == null || value.isEmpty) return null;
    if (value.length < minLength) {
      return '$field يجب أن يكون $minLength أحرف على الأقل';
    }
    return null;
  }

  /// التحقق من الحد الأقصى للطول
  static String? maxLength(
    String? value,
    int maxLength, {
    String field = 'الحقل',
  }) {
    if (value == null || value.isEmpty) return null;
    if (value.length > maxLength) {
      return '$field يجب ألا يتجاوز $maxLength حرف';
    }
    return null;
  }

  // ========== التحقق من البريد الإلكتروني ==========

  /// التحقق من صحة البريد الإلكتروني
  static String? email(String? value) {
    if (value == null || value.isEmpty) return null;
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'البريد الإلكتروني غير صحيح';
    }
    return null;
  }

  // ========== التحقق من رقم الهاتف ==========

  /// التحقق من صحة رقم الهاتف اليمني
  static String? yemenPhone(String? value) {
    if (value == null || value.isEmpty) return null;
    
    // إزالة المسافات والرموز
    final cleanPhone = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // التحقق من رقم يمني (يبدأ بـ 7 ويتكون من 9 أرقام)
    final yemenPhoneRegex = RegExp(r'^(967)?7[0-9]{8}$');
    
    if (!yemenPhoneRegex.hasMatch(cleanPhone)) {
      return 'رقم الهاتف غير صحيح (يجب أن يبدأ بـ 7 ويتكون من 9 أرقام)';
    }
    return null;
  }

  /// التحقق من صحة رقم الهاتف العام
  static String? phone(String? value) {
    if (value == null || value.isEmpty) return null;
    
    final cleanPhone = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    if (cleanPhone.length < 9 || cleanPhone.length > 15) {
      return 'رقم الهاتف يجب أن يكون بين 9 و 15 رقم';
    }
    
    if (!RegExp(r'^[0-9+]+$').hasMatch(cleanPhone)) {
      return 'رقم الهاتف يجب أن يحتوي على أرقام فقط';
    }
    
    return null;
  }
  
  /// التحقق من صحة رقم الهاتف (اسم بديل)
  static bool isValidPhone(String? value) {
    return phone(value) == null;
  }

  // ========== التحقق من الأرقام ==========

  /// التحقق من أن القيمة رقم
  static String? number(String? value, {String field = 'الحقل'}) {
    if (value == null || value.isEmpty) return null;
    
    if (double.tryParse(value) == null) {
      return '$field يجب أن يكون رقماً';
    }
    return null;
  }

  /// التحقق من أن القيمة رقم صحيح
  static String? integer(String? value, {String field = 'الحقل'}) {
    if (value == null || value.isEmpty) return null;
    
    if (int.tryParse(value) == null) {
      return '$field يجب أن يكون رقماً صحيحاً';
    }
    return null;
  }

  /// التحقق من أن القيمة رقم موجب
  static String? positive(String? value, {String field = 'الحقل'}) {
    if (value == null || value.isEmpty) return null;
    
    final numValue = double.tryParse(value);
    if (numValue == null) {
      return '$field يجب أن يكون رقماً';
    }
    
    if (numValue <= 0) {
      return '$field يجب أن يكون أكبر من صفر';
    }
    return null;
  }

  /// التحقق من الحد الأدنى للقيمة
  static String? min(
    String? value,
    double minValue, {
    String field = 'الحقل',
  }) {
    if (value == null || value.isEmpty) return null;
    
    final numValue = double.tryParse(value);
    if (numValue == null) {
      return '$field يجب أن يكون رقماً';
    }
    
    if (numValue < minValue) {
      return '$field يجب أن يكون $minValue على الأقل';
    }
    return null;
  }

  /// التحقق من الحد الأقصى للقيمة
  static String? max(
    String? value,
    double maxValue, {
    String field = 'الحقل',
  }) {
    if (value == null || value.isEmpty) return null;
    
    final numValue = double.tryParse(value);
    if (numValue == null) {
      return '$field يجب أن يكون رقماً';
    }
    
    if (numValue > maxValue) {
      return '$field يجب ألا يتجاوز $maxValue';
    }
    return null;
  }

  /// التحقق من أن القيمة ضمن نطاق
  static String? range(
    String? value,
    double minValue,
    double maxValue, {
    String field = 'الحقل',
  }) {
    if (value == null || value.isEmpty) return null;
    
    final numValue = double.tryParse(value);
    if (numValue == null) {
      return '$field يجب أن يكون رقماً';
    }
    
    if (numValue < minValue || numValue > maxValue) {
      return '$field يجب أن يكون بين $minValue و $maxValue';
    }
    return null;
  }

  // ========== التحقق من كلمة المرور ==========

  /// التحقق من قوة كلمة المرور
  static String? password(String? value) {
    if (value == null || value.isEmpty) return null;
    
    if (value.length < 8) {
      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    }
    
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'كلمة المرور يجب أن تحتوي على حرف كبير واحد على الأقل';
    }
    
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'كلمة المرور يجب أن تحتوي على حرف صغير واحد على الأقل';
    }
    
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'كلمة المرور يجب أن تحتوي على رقم واحد على الأقل';
    }
    
    return null;
  }

  /// التحقق من تطابق كلمتي المرور
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) return null;
    
    if (value != password) {
      return 'كلمتا المرور غير متطابقتين';
    }
    return null;
  }

  // ========== التحقق المخصص ==========

  /// التحقق من التطابق مع نمط معين
  static String? pattern(
    String? value,
    String pattern, {
    String field = 'الحقل',
    String? message,
  }) {
    if (value == null || value.isEmpty) return null;
    
    if (!RegExp(pattern).hasMatch(value)) {
      return message ?? '$field غير صحيح';
    }
    return null;
  }

  /// التحقق من أن القيمة من ضمن قائمة
  static String? oneOf(
    String? value,
    List<String> options, {
    String field = 'الحقل',
  }) {
    if (value == null || value.isEmpty) return null;
    
    if (!options.contains(value)) {
      return '$field يجب أن يكون أحد الخيارات المتاحة';
    }
    return null;
  }

  // ========== دمج عدة تحققات ==========

  /// دمج عدة دوال تحقق
  static String? combine(String? value, List<String? Function(String?)> validators) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) return error;
    }
    return null;
  }

  // ========== تحققات خاصة بالتطبيق ==========

  /// التحقق من اسم العميل
  static String? customerName(String? value) {
    return combine(value, [
      (v) => required(v, field: 'اسم العميل'),
      (v) => minLength(v, 3, field: 'اسم العميل'),
      (v) => maxLength(v, 50, field: 'اسم العميل'),
    ]);
  }

  /// التحقق من المبلغ المالي
  static String? amount(String? value) {
    return combine(value, [
      (v) => required(v, field: 'المبلغ'),
      (v) => number(v, field: 'المبلغ'),
      (v) => positive(v, field: 'المبلغ'),
    ]);
  }

  /// التحقق من التقييم
  static String? rating(String? value) {
    return combine(value, [
      (v) => integer(v, field: 'التقييم'),
      (v) => range(v, 1, 5, field: 'التقييم'),
    ]);
  }

  // ========== أسماء بديلة للتوافق ==========

  /// التحقق من البريد الإلكتروني (اسم بديل)
  static String? validateEmail(String? value) => email(value);

  /// التحقق من كلمة المرور (اسم بديل)
  static String? validatePassword(String? value) => password(value);

  /// التحقق من رقم الهاتف (اسم بديل)
  static String? validatePhone(String? value) => phone(value);

  /// التحقق من الاسم (اسم بديل)
  static String? validateName(String? value) => customerName(value);
}
