part of 'inventory_bloc.dart';

/// أحداث المخزون
sealed class InventoryEvent extends Equatable {
  const InventoryEvent();

  @override
  List<Object?> get props => [];
}

/// حدث تحميل قائمة المخزون
class LoadInventoryListEvent extends InventoryEvent {
  final InventoryFilterType filterType;
  final int? warehouseId;
  final String? searchQuery;

  const LoadInventoryListEvent({
    this.filterType = InventoryFilterType.all,
    this.warehouseId,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [filterType, warehouseId, searchQuery];
}

/// حدث تحديث عنصر المخزون
class UpdateInventoryItemEvent extends InventoryEvent {
  final Inventory inventory;

  const UpdateInventoryItemEvent(this.inventory);

  @override
  List<Object?> get props => [inventory];
}

/// حدث تعديل كمية المخزون
class AdjustInventoryQuantityEvent extends InventoryEvent {
  final int qatTypeId;
  final String unit;
  final double newQuantity;
  final String reason;
  final int warehouseId;

  const AdjustInventoryQuantityEvent({
    required this.qatTypeId,
    required this.unit,
    required this.newQuantity,
    required this.reason,
    this.warehouseId = 1,
  });

  @override
  List<Object?> get props => [qatTypeId, unit, newQuantity, reason, warehouseId];
}

/// حدث تحميل حركات المخزون
class LoadInventoryTransactionsEvent extends InventoryEvent {
  final TransactionFilterType filterType;
  final int? qatTypeId;
  final String? transactionType;
  final String? startDate;
  final String? endDate;

  const LoadInventoryTransactionsEvent({
    this.filterType = TransactionFilterType.all,
    this.qatTypeId,
    this.transactionType,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [filterType, qatTypeId, transactionType, startDate, endDate];
}

/// حدث تحميل إحصائيات المخزون
class LoadInventoryStatisticsEvent extends InventoryEvent {
  const LoadInventoryStatisticsEvent();
}

/// حدث البحث في المخزون
class SearchInventoryEvent extends InventoryEvent {
  final String query;

  const SearchInventoryEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// حدث تحديث تصفية المخزون
class UpdateInventoryFilterEvent extends InventoryEvent {
  final InventoryFilterType filterType;
  final Map<String, dynamic>? filterOptions;

  const UpdateInventoryFilterEvent({
    required this.filterType,
    this.filterOptions,
  });

  @override
  List<Object?> get props => [filterType, filterOptions];
}

/// حدث إعادة تحميل المخزون
class RefreshInventoryEvent extends InventoryEvent {
  const RefreshInventoryEvent();
}

/// حدث حذف عنصر من المخزون
class DeleteInventoryItemEvent extends InventoryEvent {
  final int inventoryId;

  const DeleteInventoryItemEvent(this.inventoryId);

  @override
  List<Object?> get props => [inventoryId];
}

/// حدث إضافة عنصر مخزون جديد
class AddInventoryItemEvent extends InventoryEvent {
  final Inventory inventory;

  const AddInventoryItemEvent(this.inventory);

  @override
  List<Object?> get props => [inventory];
}

/// حدث التحقق من توفر المخزون
class CheckStockAvailabilityEvent extends InventoryEvent {
  final int qatTypeId;
  final String unit;
  final double requiredQuantity;
  final int warehouseId;

  const CheckStockAvailabilityEvent({
    required this.qatTypeId,
    required this.unit,
    required this.requiredQuantity,
    this.warehouseId = 1,
  });

  @override
  List<Object?> get props => [qatTypeId, unit, requiredQuantity, warehouseId];
}

// ================= أحداث المردودات =================

/// حدث تحميل المردودات
class LoadReturnsEvent extends InventoryEvent {
  final String? returnType; // مردود_مبيعات، مردود_مشتريات، null للكل
  final String? status; // معلق، مؤكد، ملغي، null للكل

  const LoadReturnsEvent({
    this.returnType,
    this.status,
  });

  @override
  List<Object?> get props => [returnType, status];
}

/// حدث إضافة مردود
class AddReturnEvent extends InventoryEvent {
  final int qatTypeId;
  final String qatTypeName;
  final String unit;
  final double quantity;
  final double unitPrice;
  final String returnReason;
  final String returnType;
  final int? customerId;
  final String? customerName;
  final int? supplierId;
  final String? supplierName;
  final int? originalSaleId;
  final int? originalPurchaseId;

  const AddReturnEvent({
    required this.qatTypeId,
    required this.qatTypeName,
    required this.unit,
    required this.quantity,
    required this.unitPrice,
    required this.returnReason,
    required this.returnType,
    this.customerId,
    this.customerName,
    this.supplierId,
    this.supplierName,
    this.originalSaleId,
    this.originalPurchaseId,
  });

  @override
  List<Object?> get props => [
    qatTypeId, qatTypeName, unit, quantity, unitPrice,
    returnReason, returnType, customerId, customerName,
    supplierId, supplierName, originalSaleId, originalPurchaseId,
  ];
}

/// حدث تأكيد مردود
class ConfirmReturnEvent extends InventoryEvent {
  final int returnId;

  const ConfirmReturnEvent(this.returnId);

  @override
  List<Object?> get props => [returnId];
}

// ================= أحداث البضاعة التالفة =================

/// حدث تحميل البضاعة التالفة
class LoadDamagedItemsEvent extends InventoryEvent {
  final String? damageType; // تلف_طبيعي، تلف_بشري، إلخ
  final String? severityLevel; // طفيف، متوسط، كبير، كارثي
  final String? status; // تحت_المراجعة، مؤكد، تم_التعامل_معه

  const LoadDamagedItemsEvent({
    this.damageType,
    this.severityLevel,
    this.status,
  });

  @override
  List<Object?> get props => [damageType, severityLevel, status];
}

/// حدث إضافة بضاعة تالفة
class AddDamagedItemEvent extends InventoryEvent {
  final int qatTypeId;
  final String qatTypeName;
  final String unit;
  final double quantity;
  final double unitCost;
  final String damageReason;
  final String damageType;
  final String severityLevel;
  final bool isInsuranceCovered;
  final double? insuranceAmount;
  final String? responsiblePerson;
  final String? batchNumber;
  final String? expiryDate;

  const AddDamagedItemEvent({
    required this.qatTypeId,
    required this.qatTypeName,
    required this.unit,
    required this.quantity,
    required this.unitCost,
    required this.damageReason,
    required this.damageType,
    required this.severityLevel,
    this.isInsuranceCovered = false,
    this.insuranceAmount,
    this.responsiblePerson,
    this.batchNumber,
    this.expiryDate,
  });

  @override
  List<Object?> get props => [
    qatTypeId, qatTypeName, unit, quantity, unitCost,
    damageReason, damageType, severityLevel, isInsuranceCovered,
    insuranceAmount, responsiblePerson, batchNumber, expiryDate,
  ];
}

/// حدث تأكيد تلف
class ConfirmDamageEvent extends InventoryEvent {
  final int damageId;
  final String? actionTaken;

  const ConfirmDamageEvent(this.damageId, {this.actionTaken});

  @override
  List<Object?> get props => [damageId, actionTaken];
}
