import '../../repositories/damaged_items_repository.dart';
import '../base/base_usecase.dart';

/// حالة استخدام الحصول على إحصائيات البضاعة التالفة
class GetDamageStatistics implements UseCase<DamageStatistics, NoParams> {
  final DamagedItemsRepository repository;

  GetDamageStatistics(this.repository);

  @override
  Future<DamageStatistics> call(NoParams params) async {
    try {
      // الحصول على الإحصائيات الأساسية
      final stats = await repository.getDamageStatistics();
      
      // الحصول على القيم الإجمالية
      final totalDamageValue = await repository.getTotalDamageValue();
      final totalInsuranceAmount = await repository.getTotalInsuranceAmount();
      
      // الحصول على تحليل الأسباب
      final reasonAnalysis = await repository.getDamageReasonAnalysis();
      
      // الحصول على تحليل القيم حسب النوع
      final valueByType = await repository.getDamageValueByType();
      
      // الحصول على أكثر الأصناف تلفاً
      final mostDamagedItems = await repository.getMostDamagedItems(10);

      return DamageStatistics(
        totalDamaged: stats['totalDamaged'] ?? 0,
        underReview: stats['underReview'] ?? 0,
        confirmed: stats['confirmed'] ?? 0,
        handled: stats['handled'] ?? 0,
        critical: stats['critical'] ?? 0,
        insuranceCovered: stats['insuranceCovered'] ?? 0,
        totalValue: totalDamageValue,
        totalInsuranceAmount: totalInsuranceAmount,
        reasonAnalysis: reasonAnalysis,
        valueByType: valueByType,
        mostDamagedItems: mostDamagedItems,
      );
    } catch (e) {
      throw Exception('فشل في الحصول على إحصائيات البضاعة التالفة: $e');
    }
  }
}

/// إحصائيات البضاعة التالفة
class DamageStatistics {
  final int totalDamaged;
  final int underReview;
  final int confirmed;
  final int handled;
  final int critical;
  final int insuranceCovered;
  final double totalValue;
  final double totalInsuranceAmount;
  final Map<String, int> reasonAnalysis;
  final Map<String, double> valueByType;
  final List<dynamic> mostDamagedItems;

  const DamageStatistics({
    required this.totalDamaged,
    required this.underReview,
    required this.confirmed,
    required this.handled,
    required this.critical,
    required this.insuranceCovered,
    required this.totalValue,
    required this.totalInsuranceAmount,
    required this.reasonAnalysis,
    required this.valueByType,
    required this.mostDamagedItems,
  });

  /// النسبة المئوية للحالات المؤكدة
  double get confirmedPercentage {
    if (totalDamaged == 0) return 0.0;
    return (confirmed / totalDamaged) * 100;
  }

  /// النسبة المئوية للحالات الحرجة
  double get criticalPercentage {
    if (totalDamaged == 0) return 0.0;
    return (critical / totalDamaged) * 100;
  }

  /// النسبة المئوية للمشمول بالتأمين
  double get insuranceCoverage {
    if (totalDamaged == 0) return 0.0;
    return (insuranceCovered / totalDamaged) * 100;
  }

  /// متوسط قيمة التلف
  double get averageDamageValue {
    if (totalDamaged == 0) return 0.0;
    return totalValue / totalDamaged;
  }

  /// أكثر سبب للتلف
  String get topDamageReason {
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

  /// أكثر نوع تلف قيمة
  String get mostCostlyDamageType {
    if (valueByType.isEmpty) return 'لا يوجد';
    
    String topType = '';
    double maxValue = 0.0;
    
    valueByType.forEach((type, value) {
      if (value > maxValue) {
        maxValue = value;
        topType = type;
      }
    });
    
    return topType.isNotEmpty ? topType : 'لا يوجد';
  }

  /// نسبة التغطية التأمينية
  double get insuranceRecoveryRate {
    if (totalValue == 0) return 0.0;
    return (totalInsuranceAmount / totalValue) * 100;
  }

  /// هل يحتاج لانتباه عاجل؟
  bool get needsUrgentAttention {
    return critical > 0 || 
           underReview > 10 ||
           totalValue > 50000 ||
           criticalPercentage > 20;
  }

  /// حالة النظام العامة
  DamageSystemStatus get systemStatus {
    if (needsUrgentAttention) return DamageSystemStatus.critical;
    if (underReview > 5 || totalValue > 20000) return DamageSystemStatus.warning;
    if (totalDamaged == 0) return DamageSystemStatus.excellent;
    return DamageSystemStatus.normal;
  }
}

/// حالة نظام التلف
enum DamageSystemStatus {
  excellent,
  normal,
  warning,
  critical,
}
