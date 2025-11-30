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
    
    // جلب من جدول الإحصائيات اليومية إن وجد
    final v = await local.getDaily(date);
    DailyStatistics? result = v == null ? null : _fromModel(v);

    // في حال عدم وجود سجل مسبق، نحاول حساب الإحصائيات من الجداول الخام
    if (result == null) {
      final raw = await local.getDailyStatistics(date);

      // إذا لم يكن هناك أي بيانات في هذا اليوم نرجع null
      if (raw.isNotEmpty) {
        final totalSales = (raw['total_sales'] as num?)?.toDouble() ?? 0.0;
        final cashSales = (raw['cash_sales'] as num?)?.toDouble() ?? 0.0;
        final creditSales = (raw['credit_sales'] as num?)?.toDouble() ?? 0.0;
        final totalPurchases =
            (raw['total_purchases'] as num?)?.toDouble() ?? 0.0;
        final totalExpenses =
            (raw['total_expenses'] as num?)?.toDouble() ?? 0.0;
        final collectedDebts =
            (raw['collected_debts'] as num?)?.toDouble() ?? 0.0;
        final newDebts = (raw['new_debts'] as num?)?.toDouble() ?? 0.0;

        // تقدير مبسط للربح الإجمالي والصافي من المجاميع المتاحة
        final grossProfit = totalSales - totalPurchases;
        final netProfit = grossProfit - totalExpenses;

        // حساب الرصيد النقدي كما في حالة الاستخدام اليومية
        final cashBalance =
            cashSales + collectedDebts - totalPurchases - totalExpenses;

        result = DailyStatistics(
          date: date,
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

        // حفظ الإحصائيات المحسوبة في جدول daily_stats للاستخدام المستقبلي
        await saveDaily(result!);
      }
    }

    // حفظ في الذاكرة المؤقتة لمدة 5 دقائق
    if (result != null) {
      _cache.set(cacheKey, result, ttl: const Duration(minutes: 5));
    }

    return result;
  }

  @override
  Future<List<DailyStatistics>> getMonthly(int year, int month) async {
    // التأكد من أن جميع أيام الشهر لديها إحصائيات في جدول daily_stats
    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;

    for (var day = 0; day < daysInMonth; day++) {
      final date = firstDay.add(Duration(days: day));
      final dateStr = date.toIso8601String().split('T')[0];

      // إذا كان اليوم موجوداً في daily_stats نتجاوزه
      final existing = await local.getDaily(dateStr);
      if (existing != null) continue;

      // حساب الإحصائيات من الجداول الخام
      final raw = await local.getDailyStatistics(dateStr);

      if (raw.isNotEmpty) {
        final totalSales = (raw['total_sales'] as num?)?.toDouble() ?? 0.0;
        final cashSales = (raw['cash_sales'] as num?)?.toDouble() ?? 0.0;
        final creditSales = (raw['credit_sales'] as num?)?.toDouble() ?? 0.0;
        final totalPurchases =
            (raw['total_purchases'] as num?)?.toDouble() ?? 0.0;
        final totalExpenses =
            (raw['total_expenses'] as num?)?.toDouble() ?? 0.0;
        final collectedDebts =
            (raw['collected_debts'] as num?)?.toDouble() ?? 0.0;
        final newDebts = (raw['new_debts'] as num?)?.toDouble() ?? 0.0;

        final grossProfit = totalSales - totalPurchases;
        final netProfit = grossProfit - totalExpenses;
        final cashBalance =
            cashSales + collectedDebts - totalPurchases - totalExpenses;

        final stats = DailyStatistics(
          date: dateStr,
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

        await saveDaily(stats);
      }
    }

    // بعد التأكد من تعبئة جميع الأيام، نجلب قائمة الشهر من جدول daily_stats
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
