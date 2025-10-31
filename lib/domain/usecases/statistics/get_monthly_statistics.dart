// ignore_for_file: public_member_api_docs

import '../../entities/daily_statistics.dart';
import '../../repositories/statistics_repository.dart';
import '../base/base_usecase.dart';

class GetMonthlyStatistics implements UseCase<List<DailyStatistics>, ({int year, int month})> {
  final StatisticsRepository repo;
  GetMonthlyStatistics(this.repo);
  @override
  Future<List<DailyStatistics>> call(({int year, int month}) params) => repo.getMonthly(params.year, params.month);
}
