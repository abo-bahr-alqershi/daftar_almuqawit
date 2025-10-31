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
    for (int m = 1; m <= 12; m++) {
      final monthList = await repo.getMonthly(year, m);
      result.addAll(monthList);
    }
    return result;
  }
}
