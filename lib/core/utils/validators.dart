// ignore_for_file: public_member_api_docs

/// أدوات التحقق من صحة المُدخلات
class Validators {
  Validators._();

  static String? required(String? v, {String field = 'الحقل'}) {
    if (v == null || v.trim().isEmpty) return '$field مطلوب';
    return null;
  }
}
