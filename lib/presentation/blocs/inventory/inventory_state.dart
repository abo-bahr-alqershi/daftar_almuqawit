part of 'inventory_bloc.dart';

/// حالات المخزون
sealed class InventoryState extends Equatable {
  const InventoryState();

  @override
  List<Object?> get props => [];
}

/// الحالة الأولية
class InventoryInitial extends InventoryState {
  const InventoryInitial();
}

/// حالة التحميل
class InventoryLoading extends InventoryState {
  const InventoryLoading();
}

/// حالة تحميل قائمة المخزون بنجاح
class InventoryListLoaded extends InventoryState {
  final List<Inventory> inventory;
  final InventoryFilterType currentFilter;
  final bool isSearchActive;
  final String? searchQuery;

  const InventoryListLoaded({
    required this.inventory,
    this.currentFilter = InventoryFilterType.all,
    this.isSearchActive = false,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [inventory, currentFilter, isSearchActive, searchQuery];

  /// نسخة محدثة من الحالة
  InventoryListLoaded copyWith({
    List<Inventory>? inventory,
    InventoryFilterType? currentFilter,
    bool? isSearchActive,
    String? searchQuery,
  }) {
    return InventoryListLoaded(
      inventory: inventory ?? this.inventory,
      currentFilter: currentFilter ?? this.currentFilter,
      isSearchActive: isSearchActive ?? this.isSearchActive,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// حالة تحميل حركات المخزون بنجاح
class InventoryTransactionsLoaded extends InventoryState {
  final List<InventoryTransaction> transactions;
  final TransactionFilterType currentFilter;

  const InventoryTransactionsLoaded({
    required this.transactions,
    this.currentFilter = TransactionFilterType.all,
  });

  @override
  List<Object?> get props => [transactions, currentFilter];
}

/// حالة تحميل إحصائيات المخزون بنجاح
class InventoryStatisticsLoaded extends InventoryState {
  final InventoryStatistics statistics;

  const InventoryStatisticsLoaded(this.statistics);

  @override
  List<Object?> get props => [statistics];
}

/// حالة نجاح العملية
class InventoryOperationSuccess extends InventoryState {
  final String message;
  final InventoryOperationType operationType;

  const InventoryOperationSuccess({
    required this.message,
    required this.operationType,
  });

  @override
  List<Object?> get props => [message, operationType];
}

/// حالة التحقق من توفر المخزون
class StockAvailabilityChecked extends InventoryState {
  final bool isAvailable;
  final double availableQuantity;
  final double requiredQuantity;
  final String unit;
  final String message;

  const StockAvailabilityChecked({
    required this.isAvailable,
    required this.availableQuantity,
    required this.requiredQuantity,
    required this.unit,
    required this.message,
  });

  @override
  List<Object?> get props => [isAvailable, availableQuantity, requiredQuantity, unit, message];
}

/// حالة الخطأ
class InventoryError extends InventoryState {
  final String message;
  final InventoryErrorType errorType;

  const InventoryError({
    required this.message,
    this.errorType = InventoryErrorType.general,
  });

  @override
  List<Object?> get props => [message, errorType];
}

/// حالة مركبة تحتوي على معلومات متعددة
class InventoryDashboardState extends InventoryState {
  final List<Inventory> inventory;
  final List<Inventory> lowStockItems;
  final InventoryStatistics statistics;
  final List<InventoryTransaction> recentTransactions;

  const InventoryDashboardState({
    required this.inventory,
    required this.lowStockItems,
    required this.statistics,
    required this.recentTransactions,
  });

  @override
  List<Object?> get props => [inventory, lowStockItems, statistics, recentTransactions];
}

/// أنواع العمليات على المخزون
enum InventoryOperationType {
  add,
  update,
  delete,
  adjust,
  transfer,
}

// ================= حالات المردودات والتالف =================

/// حالة تحميل المردودات بنجاح
class ReturnsLoadedState extends InventoryState {
  final List<dynamic> returns; // سيكون List<ReturnItem>
  final String? currentFilter;

  const ReturnsLoadedState({
    required this.returns,
    this.currentFilter,
  });

  @override
  List<Object?> get props => [returns, currentFilter];
}

/// حالة تحميل البضاعة التالفة بنجاح
class DamagedItemsLoadedState extends InventoryState {
  final List<dynamic> damagedItems; // سيكون List<DamagedItem>
  final String? currentFilter;

  const DamagedItemsLoadedState({
    required this.damagedItems,
    this.currentFilter,
  });

  @override
  List<Object?> get props => [damagedItems, currentFilter];
}

/// حالة نجاح عملية المردود
class ReturnOperationSuccess extends InventoryState {
  final String message;
  final String operationType; // add, confirm, cancel

  const ReturnOperationSuccess({
    required this.message,
    required this.operationType,
  });

  @override
  List<Object?> get props => [message, operationType];
}

/// حالة نجاح عملية التلف
class DamageOperationSuccess extends InventoryState {
  final String message;
  final String operationType; // add, confirm, handle

  const DamageOperationSuccess({
    required this.message,
    required this.operationType,
  });

  @override
  List<Object?> get props => [message, operationType];
}

/// حالة مركبة للوحة المردودات والتلف
class InventoryReturnsAndDamagesState extends InventoryState {
  final List<dynamic> recentReturns;
  final List<dynamic> recentDamages;
  final List<dynamic> pendingReturns;
  final List<dynamic> criticalDamages;
  final Map<String, dynamic> returnsStatistics;
  final Map<String, dynamic> damagesStatistics;

  const InventoryReturnsAndDamagesState({
    required this.recentReturns,
    required this.recentDamages,
    required this.pendingReturns,
    required this.criticalDamages,
    required this.returnsStatistics,
    required this.damagesStatistics,
  });

  @override
  List<Object?> get props => [
    recentReturns, recentDamages, pendingReturns, 
    criticalDamages, returnsStatistics, damagesStatistics,
  ];
}

/// أنواع أخطاء المخزون
enum InventoryErrorType {
  general,
  network,
  validation,
  notFound,
  insufficientStock,
  permission,
  returnError,
  damageError,
}
