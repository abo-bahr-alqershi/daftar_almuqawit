// ignore_for_file: public_member_api_docs

import 'package:intl/intl.dart';
import '../../entities/daily_statistics.dart';
import '../../repositories/statistics_repository.dart';
import '../base/base_usecase.dart';

class GetWeeklyReport implements UseCase<List<DailyStatistics>, String> {
  final StatisticsRepository repo;
  GetWeeklyReport(this.repo);
  @override
  Future<List<DailyStatistics>> call(String startDate) async {
    // startDate بصيغة YYYY-MM-DD
    final List<DailyStatistics> result = [];
    final df = DateFormat('yyyy-MM-dd');
    DateTime start = df.parse(startDate);
    for (int i = 0; i < 7; i++) {
      final day = df.format(start.add(Duration(days: i)));
      result.add(await repo.getDaily(day));
    }
    return result;
  }
}
