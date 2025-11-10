// ignore_for_file: public_member_api_docs

import 'package:intl/intl.dart';

/// توابع مساعدة للتواريخ
class DateUtils {
  DateUtils._();

  static DateTime parseYMD(String s) => DateFormat('yyyy-MM-dd').parse(s);
  
  /// تنسيق التاريخ
  static String formatDate(String dateStr, {String format = 'dd/MM/yyyy'}) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat(format, 'ar').format(date);
    } catch (e) {
      return dateStr;
    }
  }
  
  /// تنسيق التاريخ والوقت
  static String formatDateTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy hh:mm a', 'ar').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
