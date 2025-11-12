import '../base/base_usecase.dart';
import '../../repositories/inventory_repository.dart';

/// حالة استخدام الحصول على إحصائيات المخزون
class GetInventoryStatistics implements UseCase<InventoryStatistics, NoParams> {
  final InventoryRepository repository;

  const GetInventoryStatistics(this.repository);

  @override
  Future<InventoryStatistics> call(NoParams params) async {
    try {
      final statistics = await repository.getInventoryStatistics();
      return InventoryStatistics.fromMap(statistics);
    } catch (e) {
      throw Exception('فشل في الحصول على إحصائيات المخزون: $e');
    }
  }
}

/// نموذج إحصائيات المخزون
class InventoryStatistics {
  final double totalQuantity;
  final double totalItems;
  final double lowStockItems;
  final double overStockItems;
  final double totalValue;
  final Map<String, double> valueByUnit;
  final double averageValuePerItem;

  const InventoryStatistics({
    required this.totalQuantity,
    required this.totalItems,
    required this.lowStockItems,
    required this.overStockItems,
    required this.totalValue,
    required this.valueByUnit,
    required this.averageValuePerItem,
  });

  factory InventoryStatistics.fromMap(Map<String, dynamic> map) {
    return InventoryStatistics(
      totalQuantity: (map['totalQuantity'] as num?)?.toDouble() ?? 0,
      totalItems: (map['totalItems'] as num?)?.toDouble() ?? 0,
      lowStockItems: (map['lowStockItems'] as num?)?.toDouble() ?? 0,
      overStockItems: (map['overStockItems'] as num?)?.toDouble() ?? 0,
      totalValue: (map['totalValue'] as num?)?.toDouble() ?? 0,
      valueByUnit: Map<String, double>.from(map['valueByUnit'] ?? {}),
      averageValuePerItem: (map['averageValuePerItem'] as num?)?.toDouble() ?? 0,
    );
  }

  /// نسبة المخزون المنخفض
  double get lowStockPercentage => 
      totalItems > 0 ? (lowStockItems / totalItems) * 100 : 0;

  /// نسبة المخزون الزائد
  double get overStockPercentage => 
      totalItems > 0 ? (overStockItems / totalItems) * 100 : 0;

  /// نسبة المخزون الطبيعي
  double get normalStockPercentage => 
      100 - lowStockPercentage - overStockPercentage;

  /// هل يحتاج المخزون لانتباه؟
  bool get needsAttention => lowStockItems > 0 || overStockItems > 0;

  /// الوحدة الأكثر قيمة
  String? get mostValuableUnit {
    if (valueByUnit.isEmpty) return null;
    return valueByUnit.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// قيمة الوحدة الأكثر قيمة
  double get mostValuableUnitValue {
    final unit = mostValuableUnit;
    return unit != null ? valueByUnit[unit] ?? 0 : 0;
  }

  Map<String, dynamic> toMap() {
    return {
      'totalQuantity': totalQuantity,
      'totalItems': totalItems,
      'lowStockItems': lowStockItems,
      'overStockItems': overStockItems,
      'totalValue': totalValue,
      'valueByUnit': valueByUnit,
      'averageValuePerItem': averageValuePerItem,
      'lowStockPercentage': lowStockPercentage,
      'overStockPercentage': overStockPercentage,
      'normalStockPercentage': normalStockPercentage,
      'needsAttention': needsAttention,
      'mostValuableUnit': mostValuableUnit,
      'mostValuableUnitValue': mostValuableUnitValue,
    };
  }
}
