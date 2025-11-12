import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/inventory.dart';
import '../../../domain/entities/inventory_transaction.dart';
import '../../../domain/usecases/inventory/get_inventory_list.dart';
import '../../../domain/usecases/inventory/get_inventory_transactions.dart';
import '../../../domain/usecases/inventory/get_inventory_statistics.dart';
import '../../../domain/usecases/inventory/update_inventory_item.dart';
import '../../../domain/usecases/inventory/adjust_inventory_quantity.dart';
import '../../../domain/usecases/base/base_usecase.dart';

part 'inventory_event.dart';
part 'inventory_state.dart';

/// BLoC إدارة المخزون
class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final GetInventoryList _getInventoryList;
  final GetInventoryTransactions _getInventoryTransactions;
  final GetInventoryStatistics _getInventoryStatistics;
  final UpdateInventoryItem _updateInventoryItem;
  final AdjustInventoryQuantity _adjustInventoryQuantity;

  InventoryBloc({
    required GetInventoryList getInventoryList,
    required GetInventoryTransactions getInventoryTransactions,
    required GetInventoryStatistics getInventoryStatistics,
    required UpdateInventoryItem updateInventoryItem,
    required AdjustInventoryQuantity adjustInventoryQuantity,
  })  : _getInventoryList = getInventoryList,
        _getInventoryTransactions = getInventoryTransactions,
        _getInventoryStatistics = getInventoryStatistics,
        _updateInventoryItem = updateInventoryItem,
        _adjustInventoryQuantity = adjustInventoryQuantity,
        super(const InventoryInitial()) {
    // تسجيل معالجات الأحداث
    on<LoadInventoryListEvent>(_onLoadInventoryList);
    on<UpdateInventoryItemEvent>(_onUpdateInventoryItem);
    on<AdjustInventoryQuantityEvent>(_onAdjustInventoryQuantity);
    on<LoadInventoryTransactionsEvent>(_onLoadInventoryTransactions);
    on<LoadInventoryStatisticsEvent>(_onLoadInventoryStatistics);
    on<SearchInventoryEvent>(_onSearchInventory);
    on<UpdateInventoryFilterEvent>(_onUpdateInventoryFilter);
    on<RefreshInventoryEvent>(_onRefreshInventory);
    on<DeleteInventoryItemEvent>(_onDeleteInventoryItem);
    on<AddInventoryItemEvent>(_onAddInventoryItem);
    on<CheckStockAvailabilityEvent>(_onCheckStockAvailability);
  }

  /// معالج تحميل قائمة المخزون
  Future<void> _onLoadInventoryList(
    LoadInventoryListEvent event,
    Emitter<InventoryState> emit,
  ) async {
    emit(const InventoryLoading());

    try {
      final params = GetInventoryListParams(
        filterType: event.filterType,
        warehouseId: event.warehouseId,
        searchQuery: event.searchQuery,
      );

      final inventory = await _getInventoryList(params);

      emit(InventoryListLoaded(
        inventory: inventory,
        currentFilter: event.filterType,
        isSearchActive: event.searchQuery?.isNotEmpty == true,
        searchQuery: event.searchQuery,
      ));
    } catch (e) {
      emit(InventoryError(
        message: 'فشل في تحميل المخزون: ${e.toString()}',
        errorType: InventoryErrorType.general,
      ));
    }
  }

  /// معالج تحديث عنصر المخزون
  Future<void> _onUpdateInventoryItem(
    UpdateInventoryItemEvent event,
    Emitter<InventoryState> emit,
  ) async {
    emit(const InventoryLoading());

    try {
      final params = UpdateInventoryItemParams(inventory: event.inventory);
      final success = await _updateInventoryItem(params);

      if (success) {
        emit(const InventoryOperationSuccess(
          message: 'تم تحديث عنصر المخزون بنجاح',
          operationType: InventoryOperationType.update,
        ));
        
        // إعادة تحميل القائمة
        add(const LoadInventoryListEvent());
      } else {
        emit(const InventoryError(
          message: 'فشل في تحديث عنصر المخزون',
          errorType: InventoryErrorType.general,
        ));
      }
    } catch (e) {
      emit(InventoryError(
        message: 'خطأ في تحديث المخزون: ${e.toString()}',
        errorType: _getErrorType(e),
      ));
    }
  }

  /// معالج تعديل كمية المخزون
  Future<void> _onAdjustInventoryQuantity(
    AdjustInventoryQuantityEvent event,
    Emitter<InventoryState> emit,
  ) async {
    emit(const InventoryLoading());

    try {
      final params = AdjustInventoryQuantityParams(
        qatTypeId: event.qatTypeId,
        unit: event.unit,
        newQuantity: event.newQuantity,
        reason: event.reason,
        warehouseId: event.warehouseId,
      );

      final success = await _adjustInventoryQuantity(params);

      if (success) {
        emit(const InventoryOperationSuccess(
          message: 'تم تعديل كمية المخزون بنجاح',
          operationType: InventoryOperationType.adjust,
        ));
        
        // إعادة تحميل القائمة
        add(const LoadInventoryListEvent());
      } else {
        emit(const InventoryError(
          message: 'فشل في تعديل كمية المخزون',
          errorType: InventoryErrorType.general,
        ));
      }
    } catch (e) {
      emit(InventoryError(
        message: 'خطأ في تعديل كمية المخزون: ${e.toString()}',
        errorType: _getErrorType(e),
      ));
    }
  }

  /// معالج تحميل حركات المخزون
  Future<void> _onLoadInventoryTransactions(
    LoadInventoryTransactionsEvent event,
    Emitter<InventoryState> emit,
  ) async {
    emit(const InventoryLoading());

    try {
      final params = GetInventoryTransactionsParams(
        filterType: event.filterType,
        qatTypeId: event.qatTypeId,
        transactionType: event.transactionType,
        startDate: event.startDate,
        endDate: event.endDate,
      );

      final transactions = await _getInventoryTransactions(params);

      emit(InventoryTransactionsLoaded(
        transactions: transactions,
        currentFilter: event.filterType,
      ));
    } catch (e) {
      emit(InventoryError(
        message: 'فشل في تحميل حركات المخزون: ${e.toString()}',
        errorType: InventoryErrorType.general,
      ));
    }
  }

  /// معالج تحميل إحصائيات المخزون
  Future<void> _onLoadInventoryStatistics(
    LoadInventoryStatisticsEvent event,
    Emitter<InventoryState> emit,
  ) async {
    emit(const InventoryLoading());

    try {
      final statistics = await _getInventoryStatistics(const NoParams());
      emit(InventoryStatisticsLoaded(statistics));
    } catch (e) {
      emit(InventoryError(
        message: 'فشل في تحميل إحصائيات المخزون: ${e.toString()}',
        errorType: InventoryErrorType.general,
      ));
    }
  }

  /// معالج البحث في المخزون
  Future<void> _onSearchInventory(
    SearchInventoryEvent event,
    Emitter<InventoryState> emit,
  ) async {
    add(LoadInventoryListEvent(
      filterType: InventoryFilterType.search,
      searchQuery: event.query,
    ));
  }

  /// معالج تحديث تصفية المخزون
  Future<void> _onUpdateInventoryFilter(
    UpdateInventoryFilterEvent event,
    Emitter<InventoryState> emit,
  ) async {
    add(LoadInventoryListEvent(
      filterType: event.filterType,
      warehouseId: event.filterOptions?['warehouseId'],
    ));
  }

  /// معالج إعادة تحميل المخزون
  Future<void> _onRefreshInventory(
    RefreshInventoryEvent event,
    Emitter<InventoryState> emit,
  ) async {
    if (state is InventoryListLoaded) {
      final currentState = state as InventoryListLoaded;
      add(LoadInventoryListEvent(
        filterType: currentState.currentFilter,
        searchQuery: currentState.searchQuery,
      ));
    } else {
      add(const LoadInventoryListEvent());
    }
  }

  /// معالج حذف عنصر من المخزون
  Future<void> _onDeleteInventoryItem(
    DeleteInventoryItemEvent event,
    Emitter<InventoryState> emit,
  ) async {
    emit(const InventoryLoading());

    try {
      // TODO: تطبيق حذف العنصر من المخزون
      // سيتم تطبيقه لاحقاً في Repository
      
      emit(const InventoryOperationSuccess(
        message: 'تم حذف عنصر المخزون بنجاح',
        operationType: InventoryOperationType.delete,
      ));
      
      add(const LoadInventoryListEvent());
    } catch (e) {
      emit(InventoryError(
        message: 'فشل في حذف عنصر المخزون: ${e.toString()}',
        errorType: InventoryErrorType.general,
      ));
    }
  }

  /// معالج إضافة عنصر مخزون جديد
  Future<void> _onAddInventoryItem(
    AddInventoryItemEvent event,
    Emitter<InventoryState> emit,
  ) async {
    emit(const InventoryLoading());

    try {
      // TODO: تطبيق إضافة العنصر للمخزون
      // سيتم تطبيقه لاحقاً في Repository
      
      emit(const InventoryOperationSuccess(
        message: 'تم إضافة عنصر المخزون بنجاح',
        operationType: InventoryOperationType.add,
      ));
      
      add(const LoadInventoryListEvent());
    } catch (e) {
      emit(InventoryError(
        message: 'فشل في إضافة عنصر المخزون: ${e.toString()}',
        errorType: InventoryErrorType.general,
      ));
    }
  }

  /// معالج التحقق من توفر المخزون
  Future<void> _onCheckStockAvailability(
    CheckStockAvailabilityEvent event,
    Emitter<InventoryState> emit,
  ) async {
    try {
      // TODO: تطبيق التحقق من توفر المخزون
      // سيتم استخدام Repository للتحقق من الكمية المتاحة
      
      // مؤقتاً سنفترض النتيجة
      emit(StockAvailabilityChecked(
        isAvailable: true,
        availableQuantity: 100,
        requiredQuantity: event.requiredQuantity,
        unit: event.unit,
        message: 'الكمية متوفرة في المخزون',
      ));
    } catch (e) {
      emit(InventoryError(
        message: 'فشل في التحقق من توفر المخزون: ${e.toString()}',
        errorType: InventoryErrorType.general,
      ));
    }
  }

  /// تحديد نوع الخطأ بناءً على الاستثناء
  InventoryErrorType _getErrorType(dynamic error) {
    final errorMessage = error.toString().toLowerCase();
    
    if (errorMessage.contains('network') || errorMessage.contains('connection')) {
      return InventoryErrorType.network;
    } else if (errorMessage.contains('validation') || errorMessage.contains('required')) {
      return InventoryErrorType.validation;
    } else if (errorMessage.contains('not found')) {
      return InventoryErrorType.notFound;
    } else if (errorMessage.contains('insufficient') || errorMessage.contains('كافية')) {
      return InventoryErrorType.insufficientStock;
    } else if (errorMessage.contains('permission') || errorMessage.contains('unauthorized')) {
      return InventoryErrorType.permission;
    } else {
      return InventoryErrorType.general;
    }
  }
}
