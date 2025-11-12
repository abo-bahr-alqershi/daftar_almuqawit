import '../../domain/entities/inventory.dart';
import '../../domain/entities/inventory_transaction.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/local/inventory_local_datasource.dart';
import '../datasources/local/qat_type_local_datasource.dart';

/// تطبيق مستودع المخزون
class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryLocalDataSource localDataSource;
  final QatTypeLocalDataSource qatTypeLocalDataSource;

  InventoryRepositoryImpl({
    required this.localDataSource,
    required this.qatTypeLocalDataSource,
  });

  // ================= عمليات المخزون الأساسية =================

  @override
  Future<List<Inventory>> getAllInventory() async {
    try {
      return await localDataSource.getAllInventory();
    } catch (e) {
      throw Exception('فشل في الحصول على المخزون: $e');
    }
  }

  @override
  Future<Inventory?> getInventoryById(int id) async {
    try {
      return await localDataSource.getInventoryById(id);
    } catch (e) {
      throw Exception('فشل في الحصول على عنصر المخزون: $e');
    }
  }

  @override
  Future<Inventory?> getInventoryByQatType(int qatTypeId, String unit, {int warehouseId = 1}) async {
    try {
      return await localDataSource.getInventoryByQatType(qatTypeId, unit, warehouseId: warehouseId);
    } catch (e) {
      throw Exception('فشل في الحصول على مخزون نوع القات: $e');
    }
  }

  @override
  Future<List<Inventory>> getInventoryByWarehouse(int warehouseId) async {
    try {
      return await localDataSource.getInventoryByWarehouse(warehouseId);
    } catch (e) {
      throw Exception('فشل في الحصول على مخزون المخزن: $e');
    }
  }

  @override
  Future<List<Inventory>> getLowStockInventory() async {
    try {
      return await localDataSource.getLowStockInventory();
    } catch (e) {
      throw Exception('فشل في الحصول على المخزون المنخفض: $e');
    }
  }

  @override
  Future<List<Inventory>> getOverStockInventory() async {
    try {
      return await localDataSource.getOverStockInventory();
    } catch (e) {
      throw Exception('فشل في الحصول على المخزون الزائد: $e');
    }
  }

  @override
  Future<List<Inventory>> searchInventory(String query) async {
    try {
      return await localDataSource.searchInventory(query);
    } catch (e) {
      throw Exception('فشل في البحث في المخزون: $e');
    }
  }

  // ================= عمليات تحديث المخزون =================

  @override
  Future<bool> addInventoryItem(Inventory inventory) async {
    try {
      // التحقق من عدم وجود العنصر مسبقاً
      final existing = await localDataSource.getInventoryByQatType(
        inventory.qatTypeId!,
        inventory.unit,
        warehouseId: inventory.warehouseId,
      );
      
      if (existing != null) {
        throw Exception('عنصر المخزون موجود مسبقاً');
      }

      // إنشاء عنصر المخزون مع التواريخ
      final inventoryWithName = inventory.copyWith(
        qatTypeName: inventory.qatTypeName ?? 'غير محدد',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      return await localDataSource.addInventoryItem(inventoryWithName);
    } catch (e) {
      throw Exception('فشل في إضافة عنصر المخزون: $e');
    }
  }

  @override
  Future<bool> updateInventory(Inventory inventory) async {
    try {
      final updated = inventory.copyWith(
        updatedAt: DateTime.now().toIso8601String(),
      );
      return await localDataSource.updateInventory(updated);
    } catch (e) {
      throw Exception('فشل في تحديث المخزون: $e');
    }
  }

  @override
  Future<bool> removeInventoryItem(int id) async {
    try {
      return await localDataSource.removeInventoryItem(id);
    } catch (e) {
      throw Exception('فشل في حذف عنصر المخزون: $e');
    }
  }

  @override
  Future<bool> adjustInventoryQuantity(int qatTypeId, String unit, double newQuantity, String reason, {int warehouseId = 1}) async {
    try {
      if (newQuantity < 0) {
        throw Exception('الكمية يجب أن تكون موجبة');
      }

      return await localDataSource.adjustInventoryQuantity(
        qatTypeId,
        unit,
        newQuantity,
        reason,
        warehouseId: warehouseId,
      );
    } catch (e) {
      throw Exception('فشل في تعديل كمية المخزون: $e');
    }
  }

  // ================= حركات المخزون =================

  @override
  Future<List<InventoryTransaction>> getAllTransactions() async {
    try {
      return await localDataSource.getAllTransactions();
    } catch (e) {
      throw Exception('فشل في الحصول على حركات المخزون: $e');
    }
  }

  @override
  Future<List<InventoryTransaction>> getTransactionsByQatType(int qatTypeId) async {
    try {
      return await localDataSource.getTransactionsByQatType(qatTypeId);
    } catch (e) {
      throw Exception('فشل في الحصول على حركات نوع القات: $e');
    }
  }

  @override
  Future<List<InventoryTransaction>> getTransactionsByDateRange(String startDate, String endDate) async {
    try {
      return await localDataSource.getTransactionsByDateRange(startDate, endDate);
    } catch (e) {
      throw Exception('فشل في الحصول على حركات الفترة: $e');
    }
  }

  @override
  Future<List<InventoryTransaction>> getTransactionsByType(String transactionType) async {
    try {
      return await localDataSource.getTransactionsByType(transactionType);
    } catch (e) {
      throw Exception('فشل في الحصول على حركات النوع: $e');
    }
  }

  @override
  Future<InventoryTransaction?> getTransactionById(int id) async {
    try {
      final transactions = await localDataSource.getAllTransactions();
      return transactions.where((t) => t.id == id).firstOrNull;
    } catch (e) {
      throw Exception('فشل في الحصول على الحركة: $e');
    }
  }

  @override
  Future<bool> addTransaction(InventoryTransaction transaction) async {
    try {
      return await localDataSource.addTransaction(transaction);
    } catch (e) {
      throw Exception('فشل في إضافة حركة المخزون: $e');
    }
  }

  @override
  Future<bool> updateTransaction(InventoryTransaction transaction) async {
    try {
      // لا يُسمح بتعديل حركات المخزون المؤكدة إلا في حالات خاصة
      if (transaction.isConfirmed) {
        throw Exception('لا يمكن تعديل حركة مخزون مؤكدة');
      }
      
      // TODO: تطبيق تحديث الحركة في الـ DataSource
      throw UnimplementedError('تحديث حركة المخزون غير مطبق بعد');
    } catch (e) {
      throw Exception('فشل في تحديث حركة المخزون: $e');
    }
  }

  @override
  Future<bool> deleteTransaction(int id) async {
    try {
      // لا يُسمح بحذف حركات المخزون المؤكدة
      final transaction = await getTransactionById(id);
      if (transaction == null) {
        throw Exception('الحركة غير موجودة');
      }
      
      if (transaction.isConfirmed) {
        throw Exception('لا يمكن حذف حركة مخزون مؤكدة');
      }
      
      // TODO: تطبيق حذف الحركة في الـ DataSource
      throw UnimplementedError('حذف حركة المخزون غير مطبق بعد');
    } catch (e) {
      throw Exception('فشل في حذف حركة المخزون: $e');
    }
  }

  // ================= عمليات متقدمة =================

  @override
  Future<bool> transferStock(int qatTypeId, String unit, double quantity, int fromWarehouseId, int toWarehouseId, String reason) async {
    try {
      if (quantity <= 0) {
        throw Exception('كمية التحويل يجب أن تكون موجبة');
      }
      
      if (fromWarehouseId == toWarehouseId) {
        throw Exception('لا يمكن التحويل إلى نفس المخزن');
      }

      // التحقق من توفر الكمية في المخزن المصدر
      final available = await getAvailableQuantity(qatTypeId, unit, warehouseId: fromWarehouseId);
      if (available < quantity) {
        throw Exception('الكمية المتاحة ($available $unit) غير كافية للتحويل');
      }

      // TODO: تطبيق عملية التحويل بين المخازن
      throw UnimplementedError('تحويل المخزون بين المخازن غير مطبق بعد');
    } catch (e) {
      throw Exception('فشل في تحويل المخزون: $e');
    }
  }

  @override
  Future<Map<String, double>> getStockSummary() async {
    try {
      return await localDataSource.getStockSummary();
    } catch (e) {
      throw Exception('فشل في الحصول على ملخص المخزون: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getInventoryStatistics() async {
    try {
      final summary = await getStockSummary();
      final allInventory = await getAllInventory();
      
      // حساب إحصائيات إضافية
      final valueByUnit = <String, double>{};
      double totalValue = 0;
      
      for (final item in allInventory) {
        final itemValue = item.currentQuantity * (item.averageCost ?? 0);
        valueByUnit[item.unit] = (valueByUnit[item.unit] ?? 0) + itemValue;
        totalValue += itemValue;
      }

      return {
        ...summary,
        'totalValue': totalValue,
        'valueByUnit': valueByUnit,
        'averageValuePerItem': allInventory.isEmpty ? 0 : totalValue / allInventory.length,
      };
    } catch (e) {
      throw Exception('فشل في الحصول على إحصائيات المخزون: $e');
    }
  }

  @override
  Future<bool> performStockCount(Map<int, Map<String, double>> actualCounts, String reason) async {
    try {
      // TODO: تطبيق عملية جرد المخزون
      throw UnimplementedError('عملية جرد المخزون غير مطبقة بعد');
    } catch (e) {
      throw Exception('فشل في جرد المخزون: $e');
    }
  }

  // ================= ربط مع العمليات الخارجية =================

  @override
  Future<bool> updateStockFromPurchase(int qatTypeId, String unit, double quantity, double unitCost, String purchaseNumber, int purchaseId) async {
    try {
      if (quantity <= 0) {
        throw Exception('كمية الشراء يجب أن تكون موجبة');
      }

      // الحصول على المخزون الحالي أو إنشاؤه
      var inventory = await getInventoryByQatType(qatTypeId, unit);
      
      if (inventory == null) {
        // إنشاء عنصر مخزون جديد
        inventory = Inventory(
          qatTypeId: qatTypeId,
          qatTypeName: 'نوع القات $qatTypeId',
          unit: unit,
          currentQuantity: 0,
          availableQuantity: 0,
          minimumQuantity: 0,
          createdAt: DateTime.now().toIso8601String(),
        );
        await addInventoryItem(inventory);
        inventory = await getInventoryByQatType(qatTypeId, unit);
      }

      if (inventory == null) return false;

      // حساب التكلفة المتوسطة الجديدة
      final currentValue = inventory.currentQuantity * (inventory.averageCost ?? 0);
      final purchaseValue = quantity * unitCost;
      final newTotalQuantity = inventory.currentQuantity + quantity;
      final newAverageCost = newTotalQuantity > 0 
          ? (currentValue + purchaseValue) / newTotalQuantity 
          : unitCost;

      // تحديث المخزون
      final updatedInventory = inventory.copyWith(
        currentQuantity: newTotalQuantity,
        availableQuantity: newTotalQuantity - inventory.reservedQuantity,
        averageCost: newAverageCost,
        lastPurchaseDate: DateTime.now().toIso8601String().split('T')[0],
        updatedAt: DateTime.now().toIso8601String(),
      );

      final updateSuccess = await updateInventory(updatedInventory);
      if (!updateSuccess) return false;

      // إضافة حركة المخزون
      final transaction = InventoryTransaction(
        transactionDate: DateTime.now().toIso8601String().split('T')[0],
        transactionTime: DateTime.now().toIso8601String().split('T')[1].split('.')[0],
        transactionType: 'شراء',
        transactionNumber: purchaseNumber,
        qatTypeId: qatTypeId,
        qatTypeName: inventory.qatTypeName ?? 'غير محدد',
        unit: unit,
        warehouseId: inventory.warehouseId,
        warehouseName: inventory.warehouseName,
        quantityBefore: inventory.currentQuantity,
        quantityChange: quantity,
        quantityAfter: newTotalQuantity,
        unitCost: unitCost,
        totalCost: purchaseValue,
        referenceType: 'purchase',
        referenceId: purchaseId,
        createdAt: DateTime.now().toIso8601String(),
      );

      return await addTransaction(transaction);
    } catch (e) {
      throw Exception('فشل في تحديث المخزون من الشراء: $e');
    }
  }

  @override
  Future<bool> updateStockFromSale(int qatTypeId, String unit, double quantity, String saleNumber, int saleId) async {
    try {
      if (quantity <= 0) {
        throw Exception('كمية البيع يجب أن تكون موجبة');
      }

      // التحقق من توفر المخزون
      final inventory = await getInventoryByQatType(qatTypeId, unit);
      if (inventory == null) {
        throw Exception('الصنف غير موجود في المخزون');
      }

      if (inventory.availableQuantity < quantity) {
        throw Exception('الكمية المتاحة (${inventory.availableQuantity} $unit) غير كافية');
      }

      // تحديث المخزون
      final newQuantity = inventory.currentQuantity - quantity;
      final updatedInventory = inventory.copyWith(
        currentQuantity: newQuantity,
        availableQuantity: newQuantity - inventory.reservedQuantity,
        lastSaleDate: DateTime.now().toIso8601String().split('T')[0],
        updatedAt: DateTime.now().toIso8601String(),
      );

      final updateSuccess = await updateInventory(updatedInventory);
      if (!updateSuccess) return false;

      // إضافة حركة المخزون
      final transaction = InventoryTransaction(
        transactionDate: DateTime.now().toIso8601String().split('T')[0],
        transactionTime: DateTime.now().toIso8601String().split('T')[1].split('.')[0],
        transactionType: 'بيع',
        transactionNumber: saleNumber,
        qatTypeId: qatTypeId,
        qatTypeName: inventory.qatTypeName ?? 'غير محدد',
        unit: unit,
        warehouseId: inventory.warehouseId,
        warehouseName: inventory.warehouseName,
        quantityBefore: inventory.currentQuantity,
        quantityChange: -quantity,
        quantityAfter: newQuantity,
        unitCost: inventory.averageCost,
        totalCost: quantity * (inventory.averageCost ?? 0),
        referenceType: 'sale',
        referenceId: saleId,
        createdAt: DateTime.now().toIso8601String(),
      );

      return await addTransaction(transaction);
    } catch (e) {
      throw Exception('فشل في تحديث المخزون من البيع: $e');
    }
  }

  @override
  Future<bool> updateStockFromReturn(int qatTypeId, String unit, double quantity, String returnReason, String referenceNumber, int referenceId) async {
    try {
      if (quantity <= 0) {
        throw Exception('كمية المرتجع يجب أن تكون موجبة');
      }

      // الحصول على المخزون أو إنشاؤه
      var inventory = await getInventoryByQatType(qatTypeId, unit);
      
      if (inventory == null) {
        inventory = Inventory(
          qatTypeId: qatTypeId,
          qatTypeName: 'نوع القات $qatTypeId',
          unit: unit,
          currentQuantity: 0,
          availableQuantity: 0,
          minimumQuantity: 0,
          createdAt: DateTime.now().toIso8601String(),
        );
        await addInventoryItem(inventory);
        inventory = await getInventoryByQatType(qatTypeId, unit);
      }

      if (inventory == null) return false;

      // تحديث المخزون
      final newQuantity = inventory.currentQuantity + quantity;
      final updatedInventory = inventory.copyWith(
        currentQuantity: newQuantity,
        availableQuantity: newQuantity - inventory.reservedQuantity,
        updatedAt: DateTime.now().toIso8601String(),
      );

      final updateSuccess = await updateInventory(updatedInventory);
      if (!updateSuccess) return false;

      // إضافة حركة المخزون
      final transaction = InventoryTransaction(
        transactionDate: DateTime.now().toIso8601String().split('T')[0],
        transactionTime: DateTime.now().toIso8601String().split('T')[1].split('.')[0],
        transactionType: 'مرتجع',
        transactionNumber: referenceNumber,
        qatTypeId: qatTypeId,
        qatTypeName: inventory.qatTypeName ?? 'غير محدد',
        unit: unit,
        warehouseId: inventory.warehouseId,
        warehouseName: inventory.warehouseName,
        quantityBefore: inventory.currentQuantity,
        quantityChange: quantity,
        quantityAfter: newQuantity,
        unitCost: inventory.averageCost,
        totalCost: quantity * (inventory.averageCost ?? 0),
        referenceType: 'return',
        referenceId: referenceId,
        reason: returnReason,
        createdAt: DateTime.now().toIso8601String(),
      );

      return await addTransaction(transaction);
    } catch (e) {
      throw Exception('فشل في تحديث المخزون من المرتجع: $e');
    }
  }

  // ================= الحصول على الكميات =================

  @override
  Future<double> getAvailableQuantity(int qatTypeId, String unit, {int warehouseId = 1}) async {
    try {
      return await localDataSource.getAvailableQuantity(qatTypeId, unit, warehouseId: warehouseId);
    } catch (e) {
      throw Exception('فشل في الحصول على الكمية المتاحة: $e');
    }
  }

  @override
  Future<Map<String, double>> getAvailableQuantitiesByQatType(int qatTypeId) async {
    try {
      final allInventory = await getAllInventory();
      final qatTypeInventory = allInventory.where((item) => item.qatTypeId == qatTypeId);
      
      final quantities = <String, double>{};
      for (final item in qatTypeInventory) {
        quantities[item.unit] = item.availableQuantity;
      }
      
      return quantities;
    } catch (e) {
      throw Exception('فشل في الحصول على كميات نوع القات: $e');
    }
  }

  @override
  Future<bool> isStockAvailable(int qatTypeId, String unit, double requiredQuantity, {int warehouseId = 1}) async {
    try {
      final availableQuantity = await getAvailableQuantity(qatTypeId, unit, warehouseId: warehouseId);
      return availableQuantity >= requiredQuantity;
    } catch (e) {
      throw Exception('فشل في التحقق من توفر المخزون: $e');
    }
  }
}
