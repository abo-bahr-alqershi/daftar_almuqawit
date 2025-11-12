import '../base/base_usecase.dart';
import '../../entities/inventory.dart';
import '../../repositories/inventory_repository.dart';

/// حالة استخدام تحديث عنصر مخزون
class UpdateInventoryItem implements UseCase<bool, UpdateInventoryItemParams> {
  final InventoryRepository repository;

  const UpdateInventoryItem(this.repository);

  @override
  Future<bool> call(UpdateInventoryItemParams params) async {
    try {
      // التحقق من صحة البيانات
      _validateInventoryData(params.inventory);

      // تحديث العنصر
      return await repository.updateInventory(params.inventory);
    } catch (e) {
      throw Exception('فشل في تحديث عنصر المخزون: $e');
    }
  }

  void _validateInventoryData(Inventory inventory) {
    if (inventory.qatTypeId == null) {
      throw Exception('معرف نوع القات مطلوب');
    }

    if (inventory.unit.isEmpty) {
      throw Exception('الوحدة مطلوبة');
    }

    if (inventory.currentQuantity < 0) {
      throw Exception('الكمية الحالية يجب أن تكون موجبة');
    }

    if (inventory.availableQuantity < 0) {
      throw Exception('الكمية المتاحة يجب أن تكون موجبة');
    }

    if (inventory.minimumQuantity < 0) {
      throw Exception('الحد الأدنى يجب أن يكون موجب');
    }

    if (inventory.maximumQuantity != null && inventory.maximumQuantity! < 0) {
      throw Exception('الحد الأقصى يجب أن يكون موجب');
    }

    if (inventory.maximumQuantity != null && 
        inventory.minimumQuantity > inventory.maximumQuantity!) {
      throw Exception('الحد الأدنى يجب أن يكون أقل من الحد الأقصى');
    }

    if (inventory.availableQuantity > inventory.currentQuantity) {
      throw Exception('الكمية المتاحة لا يمكن أن تكون أكبر من الكمية الحالية');
    }
  }
}

/// معاملات تحديث عنصر المخزون
class UpdateInventoryItemParams {
  final Inventory inventory;

  const UpdateInventoryItemParams({
    required this.inventory,
  });
}
