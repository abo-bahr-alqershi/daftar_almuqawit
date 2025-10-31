// ignore_for_file: public_member_api_docs

import '../entities/daily_statistics.dart';

abstract class StatisticsRepository {
  Future<DailyStatistics> getDaily(String date);
  Future<List<DailyStatistics>> getMonthly(int year, int month);
}
