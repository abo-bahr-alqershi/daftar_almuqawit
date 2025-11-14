// ignore_for_file: public_member_api_docs

import '../../domain/entities/daily_statistics.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../datasources/local/statistics_local_datasource.dart';
import '../models/statistics_model.dart';
import '../../core/services/local/cache_service.dart';

class StatisticsRepositoryImpl implements StatisticsRepository {
  final StatisticsLocalDataSource local;
  final CacheService _cache = CacheService.instance;
  
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
  Future<DailyStatistics?> getDaily(String date) async {
    // التحقق من الذاكرة المؤقتة أولاً
    final cacheKey = 'daily_stats_$date';
    final cached = _cache.get<DailyStatistics>(cacheKey);
    if (cached != null) return cached;
    
    // جلب من قاعدة البيانات
    final v = await local.getDaily(date);
    final result = v == null ? null : _fromModel(v);
    
    // حفظ في الذاكرة المؤقتة لمدة 5 دقائق
    if (result != null) {
      _cache.set(cacheKey, result, ttl: const Duration(minutes: 5));
    }
    
    return result;
  }

  @override
  Future<List<DailyStatistics>> getMonthly(int year, int month) async {
    final models = await local.getMonthly(year, month);
    return models.map(_fromModel).toList();
  }

  @override
  Future<void> saveDaily(DailyStatistics statistics) => local.saveDaily(statistics);
  
  @override
  Future<void> invalidateDailyStats(String date) async {
    // مسح من الكاش
    _cache.clearDailyStatsCache(date);
    
    // حذف من قاعدة البيانات
    final db = await local.db;
    await db.delete(
      'daily_stats',
      where: 'date = ?',
      whereArgs: [date],
    );
  }
  
  @override
  Future<void> clearAllCache() async {
    _cache.clearStatisticsCache();
  }
  
  @override
  Future<int> add(DailyStatistics entity) async => 0;
  
  @override
  Future<void> delete(int id) async {}
  
  @override
  Future<List<DailyStatistics>> getAll() async => [];
  
  @override
  Future<DailyStatistics?> getById(int id) async => null;
  
  @override
  Future<void> update(DailyStatistics entity) async {}
}
