import '../../domain/entities/damaged_item.dart';
import '../../domain/repositories/damaged_items_repository.dart';
import '../datasources/local/damaged_items_local_datasource.dart';

/// تطبيق مستودع البضاعة التالفة
class DamagedItemsRepositoryImpl implements DamagedItemsRepository {
  final DamagedItemsLocalDataSource localDataSource;

  DamagedItemsRepositoryImpl({required this.localDataSource});

  @override
  Future<List<DamagedItem>> getAllDamagedItems() async {
    try {
      return await localDataSource.getAllDamagedItems();
    } catch (e) {
      throw Exception('فشل في الحصول على البضاعة التالفة: $e');
    }
  }

  @override
  Future<DamagedItem?> getDamagedItemById(int id) async {
    try {
      return await localDataSource.getDamagedItemById(id);
    } catch (e) {
      throw Exception('فشل في الحصول على العنصر التالف: $e');
    }
  }

  @override
  Future<List<DamagedItem>> getDamagedItemsByType(String damageType) async {
    try {
      return await localDataSource.getDamagedItemsByType(damageType);
    } catch (e) {
      throw Exception('فشل في الحصول على التلف حسب النوع: $e');
    }
  }

  @override
  Future<List<DamagedItem>> getDamagedItemsByStatus(String status) async {
    try {
      return await localDataSource.getDamagedItemsByStatus(status);
    } catch (e) {
      throw Exception('فشل في الحصول على التلف حسب الحالة: $e');
    }
  }

  @override
  Future<List<DamagedItem>> getDamagedItemsByDateRange(String startDate, String endDate) async {
    try {
      return await localDataSource.getDamagedItemsByDateRange(startDate, endDate);
    } catch (e) {
      throw Exception('فشل في الحصول على التلف في الفترة: $e');
    }
  }

  @override
  Future<List<DamagedItem>> getDamagedItemsBySeverity(String severityLevel) async {
    try {
      return await localDataSource.getDamagedItemsBySeverity(severityLevel);
    } catch (e) {
      throw Exception('فشل في الحصول على التلف حسب الخطورة: $e');
    }
  }

  @override
  Future<List<DamagedItem>> getCriticalDamagedItems() async {
    try {
      return await localDataSource.getCriticalDamagedItems();
    } catch (e) {
      throw Exception('فشل في الحصول على التلف الحرج: $e');
    }
  }

  @override
  Future<List<DamagedItem>> getUrgentDamagedItems() async {
    try {
      final critical = await getCriticalDamagedItems();
      return critical.where((item) => item.needsUrgentAction).toList();
    } catch (e) {
      throw Exception('فشل في الحصول على التلف العاجل: $e');
    }
  }

  @override
  Future<List<DamagedItem>> getDamagedItemsByWarehouse(int warehouseId) async {
    try {
      return await localDataSource.getDamagedItemsByWarehouse(warehouseId);
    } catch (e) {
      throw Exception('فشل في الحصول على تلف المخزن: $e');
    }
  }

  @override
  Future<List<DamagedItem>> getDamagedItemsByQatType(int qatTypeId) async {
    try {
      final allItems = await localDataSource.getAllDamagedItems();
      return allItems.where((item) => item.qatTypeId == qatTypeId).toList();
    } catch (e) {
      throw Exception('فشل في الحصول على تلف النوع: $e');
    }
  }

  @override
  Future<List<DamagedItem>> getExpiredItems() async {
    try {
      return await localDataSource.getExpiredItems();
    } catch (e) {
      throw Exception('فشل في الحصول على الأصناف المنتهية: $e');
    }
  }

  @override
  Future<List<DamagedItem>> getItemsExpiringInDays(int days) async {
    try {
      return await localDataSource.getItemsExpiringInDays(days);
    } catch (e) {
      throw Exception('فشل في الحصول على الأصناف منتهية الصلاحية: $e');
    }
  }

  @override
  Future<int> addDamagedItem(DamagedItem damagedItem) async {
    try {
      return await localDataSource.addDamagedItem(damagedItem);
    } catch (e) {
      throw Exception('فشل في إضافة العنصر التالف: $e');
    }
  }

  @override
  Future<bool> updateDamagedItem(DamagedItem damagedItem) async {
    try {
      return await localDataSource.updateDamagedItem(damagedItem);
    } catch (e) {
      throw Exception('فشل في تحديث العنصر التالف: $e');
    }
  }

  @override
  Future<bool> deleteDamagedItem(int id) async {
    try {
      return await localDataSource.deleteDamagedItem(id);
    } catch (e) {
      throw Exception('فشل في حذف العنصر التالف: $e');
    }
  }

  @override
  Future<bool> confirmDamage(int id) async {
    try {
      final item = await getDamagedItemById(id);
      if (item == null) throw Exception('العنصر التالف غير موجود');
      
      final confirmed = item.copyWith(
        status: 'مؤكد',
        updatedAt: DateTime.now().toIso8601String(),
      );
      
      return await updateDamagedItem(confirmed);
    } catch (e) {
      throw Exception('فشل في تأكيد التلف: $e');
    }
  }

  @override
  Future<bool> markAsHandled(int id, String actionTaken) async {
    try {
      final item = await getDamagedItemById(id);
      if (item == null) throw Exception('العنصر التالف غير موجود');
      
      final handled = item.copyWith(
        status: 'تم_التعامل_معه',
        actionTaken: actionTaken,
        updatedAt: DateTime.now().toIso8601String(),
      );
      
      return await updateDamagedItem(handled);
    } catch (e) {
      throw Exception('فشل في تحديث حالة التلف: $e');
    }
  }

  @override
  Future<List<DamagedItem>> searchDamagedItems(String query) async {
    try {
      return await localDataSource.searchDamagedItems(query);
    } catch (e) {
      throw Exception('فشل في البحث في التلف: $e');
    }
  }

  @override
  Future<List<DamagedItem>> getPendingDamagedItems() async {
    try {
      return await getDamagedItemsByStatus('تحت_المراجعة');
    } catch (e) {
      throw Exception('فشل في الحصول على التلف المعلق: $e');
    }
  }

  @override
  Future<List<DamagedItem>> getConfirmedDamagedItems() async {
    try {
      return await getDamagedItemsByStatus('مؤكد');
    } catch (e) {
      throw Exception('فشل في الحصول على التلف المؤكد: $e');
    }
  }

  @override
  Future<List<DamagedItem>> getHandledDamagedItems() async {
    try {
      return await getDamagedItemsByStatus('تم_التعامل_معه');
    } catch (e) {
      throw Exception('فشل في الحصول على التلف المُعامل: $e');
    }
  }

  @override
  Future<List<DamagedItem>> getInsuranceCoveredItems() async {
    try {
      return await localDataSource.getInsuranceCoveredItems();
    } catch (e) {
      throw Exception('فشل في الحصول على المشمول بالتأمين: $e');
    }
  }

  @override
  Future<double> getTotalInsuranceAmount() async {
    try {
      final stats = await localDataSource.getDamageStatistics();
      return stats['totalInsuranceAmount'] ?? 0.0;
    } catch (e) {
      throw Exception('فشل في حساب مبلغ التأمين: $e');
    }
  }

  @override
  Future<List<DamagedItem>> getPendingInsuranceClaims() async {
    try {
      final covered = await getInsuranceCoveredItems();
      return covered.where((item) => item.isUnderReview || item.isConfirmed).toList();
    } catch (e) {
      throw Exception('فشل في الحصول على مطالبات التأمين: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getDamageStatistics() async {
    try {
      return await localDataSource.getDamageStatistics();
    } catch (e) {
      throw Exception('فشل في الحصول على إحصائيات التلف: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getDamageSummaryByPeriod(String startDate, String endDate) async {
    try {
      final items = await getDamagedItemsByDateRange(startDate, endDate);
      final totalValue = items.fold<double>(0.0, (sum, item) => sum + item.totalCost);
      final avgValue = items.isNotEmpty ? totalValue / items.length : 0.0;
      
      return {
        'totalItems': items.length,
        'totalValue': totalValue,
        'averageValue': avgValue,
        'criticalCount': items.where((i) => i.severityLevel == 'كبير' || i.severityLevel == 'كارثي').length,
      };
    } catch (e) {
      throw Exception('فشل في الحصول على ملخص التلف: $e');
    }
  }

  @override
  Future<double> getTotalDamageValue() async {
    try {
      final stats = await getDamageStatistics();
      return stats['totalValue'] ?? 0.0;
    } catch (e) {
      throw Exception('فشل في حساب قيمة التلف: $e');
    }
  }

  @override
  Future<double> getTotalDamageValueByType(String damageType) async {
    try {
      final items = await getDamagedItemsByType(damageType);
      return items.fold<double>(0.0, (sum, item) => sum + item.totalCost);
    } catch (e) {
      throw Exception('فشل في حساب قيمة تلف النوع: $e');
    }
  }

  @override
  Future<Map<String, int>> getDamageReasonAnalysis() async {
    try {
      return await localDataSource.getDamageReasonAnalysis();
    } catch (e) {
      throw Exception('فشل في تحليل أسباب التلف: $e');
    }
  }

  @override
  Future<Map<String, double>> getDamageValueByWarehouse() async {
    try {
      final allItems = await getAllDamagedItems();
      final Map<String, double> result = {};
      
      for (final item in allItems) {
        final warehouse = item.warehouseName;
        result[warehouse] = (result[warehouse] ?? 0.0) + item.totalCost;
      }
      
      return result;
    } catch (e) {
      throw Exception('فشل في تحليل التلف حسب المخزن: $e');
    }
  }

  @override
  Future<Map<String, double>> getDamageValueByType() async {
    try {
      return await localDataSource.getDamageValueByType();
    } catch (e) {
      throw Exception('فشل في تحليل التلف حسب النوع: $e');
    }
  }

  @override
  Future<List<DamagedItem>> getMostDamagedItems(int limit) async {
    try {
      final allItems = await getAllDamagedItems();
      
      // تجميع حسب نوع القات
      final Map<int, List<DamagedItem>> grouped = {};
      for (final item in allItems) {
        if (!grouped.containsKey(item.qatTypeId)) {
          grouped[item.qatTypeId] = [];
        }
        grouped[item.qatTypeId]!.add(item);
      }
      
      // ترتيب حسب التكلفة الإجمالية
      final sortedEntries = grouped.entries.toList()
        ..sort((a, b) {
          final totalA = a.value.fold<double>(0.0, (sum, item) => sum + item.totalCost);
          final totalB = b.value.fold<double>(0.0, (sum, item) => sum + item.totalCost);
          return totalB.compareTo(totalA);
        });
      
      return sortedEntries
          .take(limit)
          .map((entry) => entry.value.first)
          .toList();
    } catch (e) {
      throw Exception('فشل في الحصول على الأصناف الأكثر تلفاً: $e');
    }
  }

  @override
  Future<Map<String, int>> getDamageFrequencyByQatType() async {
    try {
      final allItems = await getAllDamagedItems();
      final Map<String, int> result = {};
      
      for (final item in allItems) {
        final qatType = item.qatTypeName;
        result[qatType] = (result[qatType] ?? 0) + 1;
      }
      
      return result;
    } catch (e) {
      throw Exception('فشل في تحليل تكرار التلف: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getMonthlyDamageReport(String month, String year) async {
    try {
      final startDate = '$year-${month.padLeft(2, '0')}-01';
      final endDate = '$year-${month.padLeft(2, '0')}-31';
      
      return await getDamageSummaryByPeriod(startDate, endDate);
    } catch (e) {
      throw Exception('فشل في تقرير التلف الشهري: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getWeeklyDamageReport(String startDate) async {
    try {
      final start = DateTime.parse(startDate);
      final end = start.add(const Duration(days: 6));
      
      return await getDamageSummaryByPeriod(
        startDate,
        end.toIso8601String().split('T')[0],
      );
    } catch (e) {
      throw Exception('فشل في تقرير التلف الأسبوعي: $e');
    }
  }

  @override
  Future<List<DamagedItem>> getDamageItemsByResponsiblePerson(String person) async {
    try {
      final allItems = await getAllDamagedItems();
      return allItems.where((item) => 
        item.responsiblePerson == person || 
        item.discoveredBy == person
      ).toList();
    } catch (e) {
      throw Exception('فشل في الحصول على تلف الشخص: $e');
    }
  }
}
