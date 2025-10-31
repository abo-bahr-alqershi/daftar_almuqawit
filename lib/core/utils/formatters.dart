// ignore_for_file: public_member_api_docs

import 'package:intl/intl.dart';

/// أدوات تنسيق نصوص، تواريخ، أرقام
class Formatters {
  Formatters._();

  static String currency(num value) => NumberFormat.currency(symbol: '﷼').format(value);
  static String dateYMD(DateTime d) => DateFormat('yyyy-MM-dd').format(d);
  static String timeHM(DateTime d) => DateFormat('HH:mm').format(d);
}
