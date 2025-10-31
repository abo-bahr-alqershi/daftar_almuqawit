// ignore_for_file: public_member_api_docs

import 'package:intl/intl.dart';

/// توابع مساعدة للتواريخ
class AppDateUtils {
  AppDateUtils._();

  static DateTime parseYMD(String s) => DateFormat('yyyy-MM-dd').parse(s);
}
