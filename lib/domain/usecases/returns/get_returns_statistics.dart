import '../../repositories/returns_repository.dart';
import '../base/base_usecase.dart';

/// حالة استخدام الحصول على إحصائيات المردودات
class GetReturnsStatistics implements UseCase<ReturnsStatistics, NoParams> {
  final ReturnsRepository repository;

  GetReturnsStatistics(this.repository);

  @override
  Future<ReturnsStatistics> call(NoParams params) async {
    try {
      // الحصول على الإحصائيات الأساسية
      final stats = await repository.getReturnsStatistics();
      
      // الحصول على القيم الإجمالية
      final totalReturnValue = await repository.getTotalReturnValue();
      final salesReturnValue = await repository.getTotalReturnValueByType('مردود_مبيعات');
      final purchaseReturnValue = await repository.getTotalReturnValueByType('مردود_مشتريات');
      
      // الحصول على تحليل الأسباب
      final reasonAnalysis = await repository.getReturnReasonAnalysis();
      
      // الحصول على أكثر الأصناف إرجاعاً
      final topReturnedItems = await repository.getTopReturnedItems(10);

      return ReturnsStatistics(
        totalReturns: stats['totalReturns'] ?? 0,
        salesReturns: stats['salesReturns'] ?? 0,
        purchaseReturns: stats['purchaseReturns'] ?? 0,
        pendingReturns: stats['pendingReturns'] ?? 0,
        confirmedReturns: stats['confirmedReturns'] ?? 0,
        totalValue: totalReturnValue,
        salesReturnValue: salesReturnValue,
        purchaseReturnValue: purchaseReturnValue,
        reasonAnalysis: reasonAnalysis,
        topReturnedItems: topReturnedItems,
      );
    } catch (e) {
      throw Exception('فشل في الحصول على إحصائيات المردودات: $e');
    }
  }
}

/// إحصائيات المردودات
class ReturnsStatistics {
  final int totalReturns;
  final int salesReturns;
  final int purchaseReturns;
  final int pendingReturns;
  final int confirmedReturns;
  final double totalValue;
  final double salesReturnValue;
  final double purchaseReturnValue;
  final Map<String, int> reasonAnalysis;
  final List<dynamic> topReturnedItems;

  const ReturnsStatistics({
    required this.totalReturns,
    required this.salesReturns,
    required this.purchaseReturns,
    required this.pendingReturns,
    required this.confirmedReturns,
    required this.totalValue,
    required this.salesReturnValue,
    required this.purchaseReturnValue,
    required this.reasonAnalysis,
    required this.topReturnedItems,
  });

  /// النسبة المئوية للمردودات المؤكدة
  double get confirmedPercentage {
    if (totalReturns == 0) return 0.0;
    return (confirmedReturns / totalReturns) * 100;
  }

  /// النسبة المئوية لمردود المبيعات
  double get salesReturnsPercentage {
    if (totalReturns == 0) return 0.0;
    return (salesReturns / totalReturns) * 100;
  }

  /// النسبة المئوية لمردود المشتريات
  double get purchaseReturnsPercentage {
    if (totalReturns == 0) return 0.0;
    return (purchaseReturns / totalReturns) * 100;
  }

  /// متوسط قيمة المردود
  double get averageReturnValue {
    if (totalReturns == 0) return 0.0;
    return totalValue / totalReturns;
  }

  /// أكثر سبب للإرجاع
  String get topReturnReason {
    if (reasonAnalysis.isEmpty) return 'لا يوجد';
    
    String topReason = '';
    int maxCount = 0;
    
    reasonAnalysis.forEach((reason, count) {
      if (count > maxCount) {
        maxCount = count;
        topReason = reason;
      }
    });
    
    return topReason.isNotEmpty ? topReason : 'لا يوجد';
  }

  /// هل يحتاج لانتباه؟
  bool get needsAttention {
    return pendingReturns > 5 || 
           (totalReturns > 0 && confirmedPercentage < 50) ||
           totalValue > 10000;
  }
}
