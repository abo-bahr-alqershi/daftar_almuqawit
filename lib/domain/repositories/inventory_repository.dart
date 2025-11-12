import '../entities/inventory.dart';
import '../entities/inventory_transaction.dart';

/// مستودع المخزون
/// 
/// يحتوي على العمليات الأساسية للمخزون وحركاته
abstract class InventoryRepository {
  // عمليات المخزون الأساسية
  Future<List<Inventory>> getAllInventory();
  Future<Inventory?> getInventoryById(int id);
  Future<Inventory?> getInventoryByQatType(int qatTypeId, String unit, {int warehouseId = 1});
  Future<List<Inventory>> getInventoryByWarehouse(int warehouseId);
  Future<List<Inventory>> getLowStockInventory();
  Future<List<Inventory>> getOverStockInventory();
  Future<List<Inventory>> searchInventory(String query);
  
  // عمليات تحديث المخزون
  Future<bool> updateInventory(Inventory inventory);
  Future<bool> addInventoryItem(Inventory inventory);
  Future<bool> removeInventoryItem(int id);
  Future<bool> adjustInventoryQuantity(int qatTypeId, String unit, double newQuantity, String reason, {int warehouseId = 1});
  
  // حركات المخزون
  Future<List<InventoryTransaction>> getAllTransactions();
  Future<List<InventoryTransaction>> getTransactionsByQatType(int qatTypeId);
  Future<List<InventoryTransaction>> getTransactionsByDateRange(String startDate, String endDate);
  Future<List<InventoryTransaction>> getTransactionsByType(String transactionType);
  Future<InventoryTransaction?> getTransactionById(int id);
  Future<bool> addTransaction(InventoryTransaction transaction);
  Future<bool> updateTransaction(InventoryTransaction transaction);
  Future<bool> deleteTransaction(int id);
  
  // عمليات متقدمة
  Future<bool> transferStock(int qatTypeId, String unit, double quantity, int fromWarehouseId, int toWarehouseId, String reason);
  Future<Map<String, double>> getStockSummary();
  Future<Map<String, dynamic>> getInventoryStatistics();
  Future<bool> performStockCount(Map<int, Map<String, double>> actualCounts, String reason);
  
  // تحديث المخزون من العمليات الخارجية
  Future<bool> updateStockFromPurchase(int qatTypeId, String unit, double quantity, double unitCost, String purchaseNumber, int purchaseId);
  Future<bool> updateStockFromSale(int qatTypeId, String unit, double quantity, String saleNumber, int saleId);
  Future<bool> updateStockFromReturn(int qatTypeId, String unit, double quantity, String returnReason, String referenceNumber, int referenceId);
  
  // الحصول على الكمية المتاحة
  Future<double> getAvailableQuantity(int qatTypeId, String unit, {int warehouseId = 1});
  Future<Map<String, double>> getAvailableQuantitiesByQatType(int qatTypeId);
  
  // التحقق من توفر المخزون
  Future<bool> isStockAvailable(int qatTypeId, String unit, double requiredQuantity, {int warehouseId = 1});
}
