/// نموذج الإحصائيات اليومية
/// يحتوي على إحصائيات المبيعات والمشتريات والأرباح والمقارنات

import 'base/base_model.dart';
import '../database/tables/daily_stats_table.dart';

/// نموذج بيانات الإحصائيات اليومية
class DailyStatisticsModel extends BaseModel {
  final int? id;
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

  const DailyStatisticsModel({
    this.id,
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

  factory DailyStatisticsModel.fromMap(Map<String, Object?> map) => DailyStatisticsModel(
        id: map[DailyStatsTable.cId] as int?,
        date: map[DailyStatsTable.cDate] as String,
        totalPurchases: (map[DailyStatsTable.cTotalPurchases] as num?)?.toDouble() ?? 0,
        totalSales: (map[DailyStatsTable.cTotalSales] as num?)?.toDouble() ?? 0,
        totalExpenses: (map[DailyStatsTable.cTotalExpenses] as num?)?.toDouble() ?? 0,
        cashSales: (map[DailyStatsTable.cCashSales] as num?)?.toDouble() ?? 0,
        creditSales: (map[DailyStatsTable.cCreditSales] as num?)?.toDouble() ?? 0,
        grossProfit: (map[DailyStatsTable.cGrossProfit] as num?)?.toDouble() ?? 0,
        netProfit: (map[DailyStatsTable.cNetProfit] as num?)?.toDouble() ?? 0,
        newDebts: (map[DailyStatsTable.cNewDebts] as num?)?.toDouble() ?? 0,
        collectedDebts: (map[DailyStatsTable.cCollectedDebts] as num?)?.toDouble() ?? 0,
        cashBalance: (map[DailyStatsTable.cCashBalance] as num?)?.toDouble() ?? 0,
      );

  @override
  Map<String, Object?> toMap() => {
        DailyStatsTable.cId: id,
        DailyStatsTable.cDate: date,
        DailyStatsTable.cTotalPurchases: totalPurchases,
        DailyStatsTable.cTotalSales: totalSales,
        DailyStatsTable.cTotalExpenses: totalExpenses,
        DailyStatsTable.cCashSales: cashSales,
        DailyStatsTable.cCreditSales: creditSales,
        DailyStatsTable.cGrossProfit: grossProfit,
        DailyStatsTable.cNetProfit: netProfit,
        DailyStatsTable.cNewDebts: newDebts,
        DailyStatsTable.cCollectedDebts: collectedDebts,
        DailyStatsTable.cCashBalance: cashBalance,
      };

  @override
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

  @override
  DailyStatisticsModel copyWith({
    int? id,
    String? date,
    double? totalPurchases,
    double? totalSales,
    double? totalExpenses,
    double? cashSales,
    double? creditSales,
    double? grossProfit,
    double? netProfit,
    double? newDebts,
    double? collectedDebts,
    double? cashBalance,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? firebaseId,
    String? syncStatus,
  }) =>
      DailyStatisticsModel(
        id: id ?? this.id,
        date: date ?? this.date,
        totalPurchases: totalPurchases ?? this.totalPurchases,
        totalSales: totalSales ?? this.totalSales,
        totalExpenses: totalExpenses ?? this.totalExpenses,
        cashSales: cashSales ?? this.cashSales,
        creditSales: creditSales ?? this.creditSales,
        grossProfit: grossProfit ?? this.grossProfit,
        netProfit: netProfit ?? this.netProfit,
        newDebts: newDebts ?? this.newDebts,
        collectedDebts: collectedDebts ?? this.collectedDebts,
        cashBalance: cashBalance ?? this.cashBalance,
      );

  /// حساب نسبة الربح الإجمالي
  double get grossProfitMargin {
    if (totalSales == 0) return 0;
    return (grossProfit / totalSales) * 100;
  }

  /// حساب نسبة الربح الصافي
  double get netProfitMargin {
    if (totalSales == 0) return 0;
    return (netProfit / totalSales) * 100;
  }

  /// حساب نسبة المبيعات النقدية
  double get cashSalesPercentage {
    if (totalSales == 0) return 0;
    return (cashSales / totalSales) * 100;
  }

  /// حساب نسبة المبيعات الآجلة
  double get creditSalesPercentage {
    if (totalSales == 0) return 0;
    return (creditSales / totalSales) * 100;
  }

  /// المقارنة مع يوم آخر
  Map<String, double> compareWith(DailyStatisticsModel other) {
    return {
      'salesGrowth': _calculateGrowth(other.totalSales, totalSales),
      'purchasesGrowth': _calculateGrowth(other.totalPurchases, totalPurchases),
      'profitGrowth': _calculateGrowth(other.netProfit, netProfit),
      'expensesGrowth': _calculateGrowth(other.totalExpenses, totalExpenses),
    };
  }

  /// حساب نسبة النمو
  double _calculateGrowth(double oldValue, double newValue) {
    if (oldValue == 0) return newValue > 0 ? 100 : 0;
    return ((newValue - oldValue) / oldValue) * 100;
  }

  /// التنبؤ بالمبيعات بناءً على المتوسط
  static double predictSales(List<DailyStatisticsModel> history) {
    if (history.isEmpty) return 0;
    final total = history.fold<double>(0, (sum, stat) => sum + stat.totalSales);
    return total / history.length;
  }

  @override
  List<Object?> get props => [
    id, date, totalPurchases, totalSales, totalExpenses,
    cashSales, creditSales, grossProfit, netProfit,
    newDebts, collectedDebts, cashBalance
  ];
}
