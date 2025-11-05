// ignore_for_file: public_member_api_docs

import 'base/base_entity.dart';

/// كيان الإحصائيات اليومية
class DailyStatistics extends BaseEntity {
  final String date;
  final double totalPurchases;
  final double totalSales;
  final double totalExpenses;
  final double cashSales;
  final double creditSales;
  final double grossProfit;
  final double netProfit;
  final double newDebts;
  final double collectedDebts;
  final double cashBalance;

  const DailyStatistics({
    super.id,
    required this.date,
    this.totalPurchases = 0,
    this.totalSales = 0,
    this.totalExpenses = 0,
    this.cashSales = 0,
    this.creditSales = 0,
    this.grossProfit = 0,
    this.netProfit = 0,
    this.newDebts = 0,
    this.collectedDebts = 0,
    this.cashBalance = 0,
  });
  
  /// تحويل إلى JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date,
    'totalPurchases': totalPurchases,
    'totalSales': totalSales,
    'totalExpenses': totalExpenses,
    'cashSales': cashSales,
    'creditSales': creditSales,
    'grossProfit': grossProfit,
    'netProfit': netProfit,
    'newDebts': newDebts,
    'collectedDebts': collectedDebts,
    'cashBalance': cashBalance,
  };
}
