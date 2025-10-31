// ignore_for_file: public_member_api_docs

import '../../domain/entities/daily_statistics.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../datasources/local/statistics_local_datasource.dart';
import '../models/statistics_model.dart';

class StatisticsRepositoryImpl implements StatisticsRepository {
  final StatisticsLocalDataSource local;
  StatisticsRepositoryImpl(this.local);

  DailyStatistics _fromModel(DailyStatisticsModel m) => DailyStatistics(
        id: m.id,
        date: m.date,
        totalPurchases: m.totalPurchases,
        totalSales: m.totalSales,
        totalExpenses: m.totalExpenses,
        cashSales: m.cashSales,
        creditSales: m.creditSales,
        grossProfit: m.grossProfit,
        netProfit: m.netProfit,
        newDebts: m.newDebts,
        collectedDebts: m.collectedDebts,
        cashBalance: m.cashBalance,
      );

  @override
  Future<DailyStatistics> getDaily(String date) async {
    final v = await local.getDaily(date);
    return v == null ? DailyStatistics(date: date) : _fromModel(v);
  }

  @override
  Future<List<DailyStatistics>> getMonthly(int year, int month) async =>
      (await local.getMonthly(year, month)).map(_fromModel).toList();
}
