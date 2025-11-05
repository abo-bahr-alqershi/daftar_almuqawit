// ignore_for_file: public_member_api_docs

import 'package:intl/intl.dart';
import '../../entities/daily_statistics.dart';
import '../../repositories/statistics_repository.dart';
import '../base/base_usecase.dart';

class GetWeeklyReport implements UseCase<List<DailyStatistics>, String> {
  final StatisticsRepository repo;
  GetWeeklyReport(this.repo);
  @override
  Future<List<DailyStatistics>> call(String weekStart) async {
    final List<DailyStatistics> weekStats = [];
    
    for (int i = 0; i < 7; i++) {
      final date = DateTime.parse(weekStart).add(Duration(days: i));
      final dateStr = date.toIso8601String().split('T')[0];
      final dailyStats = await repo.getDaily(dateStr);
      if (dailyStats != null) {
        weekStats.add(dailyStats);
      }
    }
    
    return weekStats;
  }
}
