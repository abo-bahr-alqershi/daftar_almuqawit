// ignore_for_file: public_member_api_docs

/// تحويل الأرقام إلى عربية وبالعكس
class ArabicNumbers {
  ArabicNumbers._();

  static const _west = ['0','1','2','3','4','5','6','7','8','9'];
  static const _east = ['٠','١','٢','٣','٤','٥','٦','٧','٨','٩'];

  static String toArabic(String input) => input
      .split('')
      .map((c) => _west.contains(c) ? _east[int.parse(c)] : c)
      .join();
}
