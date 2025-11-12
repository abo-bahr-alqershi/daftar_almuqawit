import '../base/base_usecase.dart';
import '../../entities/inventory.dart';
import '../../repositories/inventory_repository.dart';

/// حالة استخدام الحصول على قائمة المخزون
class GetInventoryList implements UseCase<List<Inventory>, GetInventoryListParams> {
  final InventoryRepository repository;

  const GetInventoryList(this.repository);

  @override
  Future<List<Inventory>> call(GetInventoryListParams params) async {
    try {
      switch (params.filterType) {
        case InventoryFilterType.all:
          return await repository.getAllInventory();
        case InventoryFilterType.lowStock:
          return await repository.getLowStockInventory();
        case InventoryFilterType.overStock:
          return await repository.getOverStockInventory();
        case InventoryFilterType.warehouse:
          if (params.warehouseId == null) {
            throw Exception('معرف المخزن مطلوب للتصفية بالمخزن');
          }
          return await repository.getInventoryByWarehouse(params.warehouseId!);
        case InventoryFilterType.search:
          if (params.searchQuery == null || params.searchQuery!.isEmpty) {
            return await repository.getAllInventory();
          }
          return await repository.searchInventory(params.searchQuery!);
      }
    } catch (e) {
      throw Exception('فشل في الحصول على قائمة المخزون: $e');
    }
  }
}

/// معاملات الحصول على قائمة المخزون
class GetInventoryListParams {
  final InventoryFilterType filterType;
  final int? warehouseId;
  final String? searchQuery;

  const GetInventoryListParams({
    this.filterType = InventoryFilterType.all,
    this.warehouseId,
    this.searchQuery,
  });
}

/// أنواع تصفية المخزون
enum InventoryFilterType {
  all,
  lowStock,
  overStock,
  warehouse,
  search,
}
