import 'base/base_entity.dart';

/// كيان المخزون
/// 
/// يمثل الكمية الحالية لصنف معين في مخزن معين
class Inventory extends BaseEntity {
  final int? qatTypeId;
  final String? qatTypeName;
  final String unit;
  final int warehouseId;
  final String warehouseName;
  final double currentQuantity;
  final double reservedQuantity;
  final double availableQuantity;
  final double minimumQuantity;
  final double? maximumQuantity;
  final String? lastPurchaseDate;
  final String? lastSaleDate;
  final double? averageCost;
  final String? notes;
  final String? createdAt;
  final String? updatedAt;
  final String? lastUpdatedBy;

  const Inventory({
    super.id,
    required this.qatTypeId,
    this.qatTypeName,
    required this.unit,
    this.warehouseId = 1,
    this.warehouseName = 'المخزن الرئيسي',
    this.currentQuantity = 0,
    this.reservedQuantity = 0,
    this.availableQuantity = 0,
    this.minimumQuantity = 0,
    this.maximumQuantity,
    this.lastPurchaseDate,
    this.lastSaleDate,
    this.averageCost,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.lastUpdatedBy,
  });

  /// هل المخزون أقل من الحد الأدنى؟
  bool get isLowStock => currentQuantity <= minimumQuantity;

  /// هل المخزون أعلى من الحد الأقصى؟
  bool get isOverStock => maximumQuantity != null && currentQuantity >= maximumQuantity!;

  /// هل المخزون فارغ؟
  bool get isEmpty => currentQuantity <= 0;

  /// نسبة الامتلاء (للمخازن ذات الحد الأقصى)
  double? get fillPercentage {
    if (maximumQuantity == null || maximumQuantity == 0) return null;
    return (currentQuantity / maximumQuantity!) * 100;
  }

  Inventory copyWith({
    int? id,
    int? qatTypeId,
    String? qatTypeName,
    String? unit,
    int? warehouseId,
    String? warehouseName,
    double? currentQuantity,
    double? reservedQuantity,
    double? availableQuantity,
    double? minimumQuantity,
    double? maximumQuantity,
    String? lastPurchaseDate,
    String? lastSaleDate,
    double? averageCost,
    String? notes,
    String? createdAt,
    String? updatedAt,
    String? lastUpdatedBy,
  }) {
    return Inventory(
      id: id ?? this.id,
      qatTypeId: qatTypeId ?? this.qatTypeId,
      qatTypeName: qatTypeName ?? this.qatTypeName,
      unit: unit ?? this.unit,
      warehouseId: warehouseId ?? this.warehouseId,
      warehouseName: warehouseName ?? this.warehouseName,
      currentQuantity: currentQuantity ?? this.currentQuantity,
      reservedQuantity: reservedQuantity ?? this.reservedQuantity,
      availableQuantity: availableQuantity ?? this.availableQuantity,
      minimumQuantity: minimumQuantity ?? this.minimumQuantity,
      maximumQuantity: maximumQuantity ?? this.maximumQuantity,
      lastPurchaseDate: lastPurchaseDate ?? this.lastPurchaseDate,
      lastSaleDate: lastSaleDate ?? this.lastSaleDate,
      averageCost: averageCost ?? this.averageCost,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastUpdatedBy: lastUpdatedBy ?? this.lastUpdatedBy,
    );
  }
}
