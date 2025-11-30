// ignore_for_file: public_member_api_docs

import '../../entities/daily_statistics.dart';
import '../../repositories/statistics_repository.dart';
import '../base/base_usecase.dart';

class GetYearlyReport implements UseCase<List<DailyStatistics>, int> {
  final StatisticsRepository repo;

  GetYearlyReport(this.repo);

  @override
  Future<List<DailyStatistics>> call(int year) async {
    final List<DailyStatistics> result = [];

    for (int month = 1; month <= 12; month++) {
      // جلب إحصائيات جميع أيام الشهر
      final days = await repo.getMonthly(year, month);

      double totalSales = 0;
      double totalPurchases = 0;
      double totalExpenses = 0;
      double cashSales = 0;
      double creditSales = 0;
      double newDebts = 0;
      double collectedDebts = 0;

      for (final day in days) {
        totalSales += day.totalSales;
        totalPurchases += day.totalPurchases;
        totalExpenses += day.totalExpenses;
        cashSales += day.cashSales;
        creditSales += day.creditSales;
        newDebts += day.newDebts;
        collectedDebts += day.collectedDebts;
      }

      // إذا لم تكن هناك بيانات لهذا الشهر، نضيف سجلًا بقيم صفرية للحفاظ على 12 شهرًا
      final grossProfit = totalSales - totalPurchases;
      final netProfit = grossProfit - totalExpenses;
      final cashBalance = cashSales + collectedDebts - totalPurchases - totalExpenses;

      final monthStr = month.toString().padLeft(2, '0');
      final aggregated = DailyStatistics(
        // نمثل الشهر بيوم أول الشهر لسهولة التصدير والعرض
        date: '$year-$monthStr-01',
        totalPurchases: totalPurchases,
        totalSales: totalSales,
        totalExpenses: totalExpenses,
        cashSales: cashSales,
        creditSales: creditSales,
        grossProfit: grossProfit,
        netProfit: netProfit,
        newDebts: newDebts,
        collectedDebts: collectedDebts,
        cashBalance: cashBalance,
      );

      result.add(aggregated);
    }

    return result;
  }
}
