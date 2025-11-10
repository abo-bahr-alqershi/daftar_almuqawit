// ignore_for_file: public_member_api_docs

import 'package:intl/intl.dart';

/// توابع مساعدة للتواريخ
class DateUtils {
  DateUtils._();

  static DateTime parseYMD(String s) => DateFormat('yyyy-MM-dd').parse(s);
  
  /// تنسيق التاريخ من String
  static String formatDate(dynamic date, {String format = 'dd/MM/yyyy'}) {
    try {
      if (date is DateTime) {
        return DateFormat(format, 'ar').format(date);
      } else if (date is String) {
        final parsedDate = DateTime.parse(date);
        return DateFormat(format, 'ar').format(parsedDate);
      }
      return date.toString();
    } catch (e) {
      return date.toString();
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
