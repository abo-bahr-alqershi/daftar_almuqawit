/// حالة استخدام إبطال الإحصائيات اليومية
/// تقوم بحذف الإحصائيات المحفوظة لإجبار النظام على إعادة حسابها

import '../../repositories/statistics_repository.dart';
import '../base/base_usecase.dart';

/// حالة استخدام إبطال الإحصائيات
class InvalidateDailyStatistics implements UseCase<void, InvalidateDailyStatisticsParams> {
  final StatisticsRepository repository;
  
  const InvalidateDailyStatistics(this.repository);
  
  @override
  Future<void> call(InvalidateDailyStatisticsParams params) async {
    try {
      if (params.date != null) {
        // إبطال يوم محدد
        await repository.invalidateDailyStats(params.date!);
      } else {
        // مسح جميع الكاش
        await repository.clearAllCache();
      }
    } catch (e) {
      throw Exception('فشل في إبطال الإحصائيات: $e');
    }
  }
}

/// معاملات إبطال الإحصائيات
class InvalidateDailyStatisticsParams {
  /// التاريخ المراد إبطال إحصائياته (null لمسح الكل)
  final String? date;
  
  const InvalidateDailyStatisticsParams({this.date});
}
