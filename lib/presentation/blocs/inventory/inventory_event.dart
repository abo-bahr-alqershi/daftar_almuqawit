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
