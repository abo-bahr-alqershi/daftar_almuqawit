import 'base/base_entity.dart';

/// كيان حركة المخزون
/// 
/// يمثل حركة واحدة على المخزون (إضافة، سحب، تحويل، إلخ)
class InventoryTransaction extends BaseEntity {
  final String transactionDate;
  final String transactionTime;
  final String transactionType; // شراء، بيع، تحويل، جرد، تالف، مرتجع
  final String transactionNumber;
  final int qatTypeId;
  final String qatTypeName;
  final String unit;
  final int warehouseId;
  final String warehouseName;
  final int? toWarehouseId;
  final String? toWarehouseName;
  final double quantityBefore;
  final double quantityChange;
  final double quantityAfter;
  final double? unitCost;
  final double? totalCost;
  final String? referenceType;
  final int? referenceId;
  final String? referencePerson;
  final String? reason;
  final String? notes;
  final String status;
  final String? createdBy;
  final String? createdAt;
  final String? updatedAt;

  const InventoryTransaction({
    super.id,
    required this.transactionDate,
    required this.transactionTime,
    required this.transactionType,
    required this.transactionNumber,
    required this.qatTypeId,
    required this.qatTypeName,
    required this.unit,
    required this.warehouseId,
    required this.warehouseName,
    this.toWarehouseId,
    this.toWarehouseName,
    required this.quantityBefore,
    required this.quantityChange,
    required this.quantityAfter,
    this.unitCost,
    this.totalCost,
    this.referenceType,
    this.referenceId,
    this.referencePerson,
    this.reason,
    this.notes,
    this.status = 'مؤكد',
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  /// هل الحركة إضافة للمخزون؟
  bool get isInbound => quantityChange > 0;

  /// هل الحركة سحب من المخزون؟
  bool get isOutbound => quantityChange < 0;

  /// هل الحركة تحويل بين مخازن؟
  bool get isTransfer => transactionType == 'تحويل';

  /// هل الحركة مؤكدة؟
  bool get isConfirmed => status == 'مؤكد';

  /// القيمة المطلقة للتغيير
  double get absoluteChange => quantityChange.abs();
}
