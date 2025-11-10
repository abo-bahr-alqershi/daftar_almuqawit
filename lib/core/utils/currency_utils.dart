// ignore_for_file: public_member_api_docs

import 'package:intl/intl.dart';

/// توابع مساعدة للعملات
class CurrencyUtils {
  CurrencyUtils._();

  static double safeDouble(num? v) => (v ?? 0).toDouble();
  
  /// تنسيق المبلغ المالي
  static String format(double amount, {String symbol = 'ريال'}) {
    final formatter = NumberFormat('#,##0.00', 'ar');
    return '${formatter.format(amount)} $symbol';
  }
}
