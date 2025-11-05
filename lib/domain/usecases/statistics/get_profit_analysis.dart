// ignore_for_file: public_member_api_docs

import 'package:intl/intl.dart';
import '../../entities/daily_statistics.dart';
import '../../repositories/statistics_repository.dart';
import '../base/base_usecase.dart';

typedef ProfitRange = ({String from, String to});

class GetProfitAnalysis implements UseCase<Map<String, double>, String> {
  final StatisticsRepository repo;
  GetProfitAnalysis(this.repo);
  @override
  Future<Map<String, double>> call(String dateRange) async {
    // مبسط - حساب الأرباح ليوم واحد
    final date = DateTime.parse(dateRange);
    final dayStats = await repo.getDaily(date.toIso8601String().split('T')[0]);
    
    return {
      'gross': dayStats?.grossProfit ?? 0,
      'net': dayStats?.netProfit ?? 0,
    };
  }
}
