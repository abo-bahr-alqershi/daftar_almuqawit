import '../entities/return_item.dart';

/// مستودع المردودات
/// 
/// يحتوي على العمليات الأساسية للمردود من العملاء والموردين
abstract class ReturnsRepository {
  // العمليات الأساسية
  Future<List<ReturnItem>> getAllReturns();
  Future<ReturnItem?> getReturnById(int id);
  Future<List<ReturnItem>> getReturnsByType(String returnType);
  Future<List<ReturnItem>> getReturnsByStatus(String status);
  Future<List<ReturnItem>> getReturnsByDateRange(String startDate, String endDate);
  
  // مردود المبيعات
  Future<List<ReturnItem>> getSalesReturns();
  Future<List<ReturnItem>> getReturnsByCustomer(int customerId);
  Future<List<ReturnItem>> getReturnsForSale(int saleId);
  
  // مردود المشتريات
  Future<List<ReturnItem>> getPurchaseReturns();
  Future<List<ReturnItem>> getReturnsBySupplier(int supplierId);
  Future<List<ReturnItem>> getReturnsForPurchase(int purchaseId);
  
  // عمليات التعديل
  Future<int> addReturn(ReturnItem returnItem);
  Future<bool> updateReturn(ReturnItem returnItem);
  Future<bool> deleteReturn(int id);
  Future<bool> confirmReturn(int id);
  Future<bool> cancelReturn(int id, String reason);
  
  // البحث والتصفية
  Future<List<ReturnItem>> searchReturns(String query);
  Future<List<ReturnItem>> getReturnsByQatType(int qatTypeId);
  Future<List<ReturnItem>> getPendingReturns();
  Future<List<ReturnItem>> getConfirmedReturns();
  
  // الإحصائيات
  Future<Map<String, dynamic>> getReturnsStatistics();
  Future<Map<String, dynamic>> getReturnsSummaryByPeriod(String startDate, String endDate);
  Future<double> getTotalReturnValue();
  Future<double> getTotalReturnValueByType(String returnType);
  
  // التقارير
  Future<List<ReturnItem>> getTopReturnedItems(int limit);
  Future<Map<String, int>> getReturnReasonAnalysis();
  Future<List<ReturnItem>> getFrequentReturnCustomers(int limit);
}
