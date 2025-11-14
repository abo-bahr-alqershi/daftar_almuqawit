// ignore_for_file: public_member_api_docs

import '../entities/daily_statistics.dart';
import 'base/base_repository.dart';

abstract class StatisticsRepository extends BaseRepository<DailyStatistics> {
  Future<DailyStatistics?> getDaily(String date);
  Future<void> saveDaily(DailyStatistics statistics);
  Future<List<DailyStatistics>> getMonthly(int year, int month);
  
  /// إبطال (حذف) إحصائيات يوم محدد من الكاش وقاعدة البيانات
  Future<void> invalidateDailyStats(String date);
  
  /// مسح جميع الإحصائيات من الكاش
  Future<void> clearAllCache();
}
