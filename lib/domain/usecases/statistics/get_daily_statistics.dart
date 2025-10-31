// ignore_for_file: public_member_api_docs

import '../../entities/daily_statistics.dart';
import '../../repositories/statistics_repository.dart';
import '../base/base_usecase.dart';

class GetDailyStatistics implements UseCase<DailyStatistics, String> {
  final StatisticsRepository repo;
  GetDailyStatistics(this.repo);
  @override
  Future<DailyStatistics> call(String date) => repo.getDaily(date);
}
