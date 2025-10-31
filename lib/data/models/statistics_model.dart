// ignore_for_file: public_member_api_docs

import 'base/base_model.dart';
import '../database/tables/daily_stats_table.dart';

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
}
