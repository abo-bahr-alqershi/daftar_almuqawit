import '../entities/damaged_item.dart';

/// مستودع البضاعة التالفة
/// 
/// يحتوي على العمليات الأساسية لإدارة البضاعة التالفة في المخزون
abstract class DamagedItemsRepository {
  // العمليات الأساسية
  Future<List<DamagedItem>> getAllDamagedItems();
  Future<DamagedItem?> getDamagedItemById(int id);
  Future<List<DamagedItem>> getDamagedItemsByType(String damageType);
  Future<List<DamagedItem>> getDamagedItemsByStatus(String status);
  Future<List<DamagedItem>> getDamagedItemsByDateRange(String startDate, String endDate);
  
  // تصنيف حسب مستوى الخطورة
  Future<List<DamagedItem>> getDamagedItemsBySeverity(String severityLevel);
  Future<List<DamagedItem>> getCriticalDamagedItems(); // كبير + كارثي
  Future<List<DamagedItem>> getUrgentDamagedItems(); // تحتاج إجراء عاجل
  
  // تصنيف حسب المخزن
  Future<List<DamagedItem>> getDamagedItemsByWarehouse(int warehouseId);
  Future<List<DamagedItem>> getDamagedItemsByQatType(int qatTypeId);
  
  // حسب التواريخ المهمة
  Future<List<DamagedItem>> getExpiredItems();
  Future<List<DamagedItem>> getItemsExpiringInDays(int days);
  
  // عمليات التعديل
  Future<int> addDamagedItem(DamagedItem damagedItem);
  Future<bool> updateDamagedItem(DamagedItem damagedItem);
  Future<bool> deleteDamagedItem(int id);
  Future<bool> confirmDamage(int id);
  Future<bool> markAsHandled(int id, String actionTaken);
  
  // البحث والتصفية
  Future<List<DamagedItem>> searchDamagedItems(String query);
  Future<List<DamagedItem>> getPendingDamagedItems();
  Future<List<DamagedItem>> getConfirmedDamagedItems();
  Future<List<DamagedItem>> getHandledDamagedItems();
  
  // إدارة التأمين
  Future<List<DamagedItem>> getInsuranceCoveredItems();
  Future<double> getTotalInsuranceAmount();
  Future<List<DamagedItem>> getPendingInsuranceClaims();
  
  // الإحصائيات
  Future<Map<String, dynamic>> getDamageStatistics();
  Future<Map<String, dynamic>> getDamageSummaryByPeriod(String startDate, String endDate);
  Future<double> getTotalDamageValue();
  Future<double> getTotalDamageValueByType(String damageType);
  
  // التحليلات
  Future<Map<String, int>> getDamageReasonAnalysis();
  Future<Map<String, double>> getDamageValueByWarehouse();
  Future<Map<String, double>> getDamageValueByType();
  Future<List<DamagedItem>> getMostDamagedItems(int limit);
  Future<Map<String, int>> getDamageFrequencyByQatType();
  
  // التقارير الدورية
  Future<Map<String, dynamic>> getMonthlyDamageReport(String month, String year);
  Future<Map<String, dynamic>> getWeeklyDamageReport(String startDate);
  Future<List<DamagedItem>> getDamageItemsByResponsiblePerson(String person);
}
