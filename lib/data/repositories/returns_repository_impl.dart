import '../../domain/entities/return_item.dart';
import '../../domain/repositories/returns_repository.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/local/returns_local_datasource.dart';

/// تطبيق مستودع المردودات
class ReturnsRepositoryImpl implements ReturnsRepository {
  final ReturnsLocalDataSource localDataSource;
  final InventoryRepository? inventoryRepository;

  ReturnsRepositoryImpl({
    required this.localDataSource,
    this.inventoryRepository,
  });

  // ================= العمليات الأساسية =================

  @override
  Future<List<ReturnItem>> getAllReturns() async {
    try {
      return await localDataSource.getAllReturns();
    } catch (e) {
      throw Exception('فشل في الحصول على المردودات: $e');
    }
  }

  @override
  Future<ReturnItem?> getReturnById(int id) async {
    try {
      return await localDataSource.getReturnById(id);
    } catch (e) {
      throw Exception('فشل في الحصول على المردود: $e');
    }
  }

  @override
  Future<List<ReturnItem>> getReturnsByType(String returnType) async {
    try {
      return await localDataSource.getReturnsByType(returnType);
    } catch (e) {
      throw Exception('فشل في الحصول على مردودات النوع: $e');
    }
  }

  @override
  Future<List<ReturnItem>> getReturnsByStatus(String status) async {
    try {
      return await localDataSource.getReturnsByStatus(status);
    } catch (e) {
      throw Exception('فشل في الحصول على مردودات الحالة: $e');
    }
  }

  @override
  Future<List<ReturnItem>> getReturnsByDateRange(String startDate, String endDate) async {
    try {
      return await localDataSource.getReturnsByDateRange(startDate, endDate);
    } catch (e) {
      throw Exception('فشل في الحصول على مردودات الفترة: $e');
    }
  }

  // ================= مردود المبيعات =================

  @override
  Future<List<ReturnItem>> getSalesReturns() async {
    try {
      return await localDataSource.getSalesReturns();
    } catch (e) {
      throw Exception('فشل في الحصول على مردود المبيعات: $e');
    }
  }

  @override
  Future<List<ReturnItem>> getReturnsByCustomer(int customerId) async {
    try {
      return await localDataSource.getReturnsByCustomer(customerId);
    } catch (e) {
      throw Exception('فشل في الحصول على مردود العميل: $e');
    }
  }

  @override
  Future<List<ReturnItem>> getReturnsForSale(int saleId) async {
    try {
      final allReturns = await localDataSource.getAllReturns();
      return allReturns.where((r) => r.originalSaleId == saleId).toList();
    } catch (e) {
      throw Exception('فشل في الحصول على مردود البيع: $e');
    }
  }

  // ================= مردود المشتريات =================

  @override
  Future<List<ReturnItem>> getPurchaseReturns() async {
    try {
      return await localDataSource.getPurchaseReturns();
    } catch (e) {
      throw Exception('فشل في الحصول على مردود المشتريات: $e');
    }
  }

  @override
  Future<List<ReturnItem>> getReturnsBySupplier(int supplierId) async {
    try {
      return await localDataSource.getReturnsBySupplier(supplierId);
    } catch (e) {
      throw Exception('فشل في الحصول على مردود المورد: $e');
    }
  }

  @override
  Future<List<ReturnItem>> getReturnsForPurchase(int purchaseId) async {
    try {
      final allReturns = await localDataSource.getAllReturns();
      return allReturns.where((r) => r.originalPurchaseId == purchaseId).toList();
    } catch (e) {
      throw Exception('فشل في الحصول على مردود الشراء: $e');
    }
  }

  // ================= عمليات التعديل =================

  @override
  Future<int> addReturn(ReturnItem returnItem) async {
    try {
      // التحقق من صحة البيانات
      _validateReturnItem(returnItem);

      // إضافة المردود
      final returnId = await localDataSource.addReturn(returnItem);

      // تحديث المخزون إذا كان المردود مؤكداً
      if (returnItem.isConfirmed && inventoryRepository != null) {
        await _updateInventoryForReturn(returnItem);
      }

      return returnId;
    } catch (e) {
      throw Exception('فشل في إضافة المردود: $e');
    }
  }

  @override
  Future<bool> updateReturn(ReturnItem returnItem) async {
    try {
      _validateReturnItem(returnItem);

      final updated = returnItem.copyWith(
        updatedAt: DateTime.now().toIso8601String(),
      );

      return await localDataSource.updateReturn(updated);
    } catch (e) {
      throw Exception('فشل في تحديث المردود: $e');
    }
  }

  @override
  Future<bool> deleteReturn(int id) async {
    try {
      return await localDataSource.deleteReturn(id);
    } catch (e) {
      throw Exception('فشل في حذف المردود: $e');
    }
  }

  @override
  Future<bool> confirmReturn(int id) async {
    try {
      final returnItem = await localDataSource.getReturnById(id);
      if (returnItem == null) {
        throw Exception('المردود غير موجود');
      }

      // تأكيد المردود
      final confirmed = returnItem.copyWith(
        status: 'مؤكد',
        updatedAt: DateTime.now().toIso8601String(),
      );

      final success = await localDataSource.updateReturn(confirmed);

      // تحديث المخزون
      if (success && inventoryRepository != null) {
        await _updateInventoryForReturn(confirmed);
      }

      return success;
    } catch (e) {
      throw Exception('فشل في تأكيد المردود: $e');
    }
  }

  @override
  Future<bool> cancelReturn(int id, String reason) async {
    try {
      final returnItem = await localDataSource.getReturnById(id);
      if (returnItem == null) {
        throw Exception('المردود غير موجود');
      }

      final cancelled = returnItem.copyWith(
        status: 'ملغي',
        notes: '${returnItem.notes ?? ''}\nسبب الإلغاء: $reason',
        updatedAt: DateTime.now().toIso8601String(),
      );

      return await localDataSource.updateReturn(cancelled);
    } catch (e) {
      throw Exception('فشل في إلغاء المردود: $e');
    }
  }

  // ================= البحث والتصفية =================

  @override
  Future<List<ReturnItem>> searchReturns(String query) async {
    try {
      return await localDataSource.searchReturns(query);
    } catch (e) {
      throw Exception('فشل في البحث في المردودات: $e');
    }
  }

  @override
  Future<List<ReturnItem>> getReturnsByQatType(int qatTypeId) async {
    try {
      final allReturns = await localDataSource.getAllReturns();
      return allReturns.where((r) => r.qatTypeId == qatTypeId).toList();
    } catch (e) {
      throw Exception('فشل في الحصول على مردود النوع: $e');
    }
  }

  @override
  Future<List<ReturnItem>> getPendingReturns() async {
    try {
      return await localDataSource.getReturnsByStatus('معلق');
    } catch (e) {
      throw Exception('فشل في الحصول على المردودات المعلقة: $e');
    }
  }

  @override
  Future<List<ReturnItem>> getConfirmedReturns() async {
    try {
      return await localDataSource.getReturnsByStatus('مؤكد');
    } catch (e) {
      throw Exception('فشل في الحصول على المردودات المؤكدة: $e');
    }
  }

  // ================= الإحصائيات =================

  @override
  Future<Map<String, dynamic>> getReturnsStatistics() async {
    try {
      return await localDataSource.getReturnsStatistics();
    } catch (e) {
      throw Exception('فشل في الحصول على إحصائيات المردود: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getReturnsSummaryByPeriod(String startDate, String endDate) async {
    try {
      return await localDataSource.getReturnsSummaryByPeriod(startDate, endDate);
    } catch (e) {
      throw Exception('فشل في الحصول على ملخص المردود: $e');
    }
  }

  @override
  Future<double> getTotalReturnValue() async {
    try {
      final stats = await localDataSource.getReturnsStatistics();
      return stats['totalValue'] ?? 0.0;
    } catch (e) {
      throw Exception('فشل في حساب قيمة المردود: $e');
    }
  }

  @override
  Future<double> getTotalReturnValueByType(String returnType) async {
    try {
      final returns = await localDataSource.getReturnsByType(returnType);
      return returns.fold<double>(0.0, (sum, item) => sum + item.totalAmount);
    } catch (e) {
      throw Exception('فشل في حساب قيمة مردود النوع: $e');
    }
  }

  // ================= التقارير =================

  @override
  Future<List<ReturnItem>> getTopReturnedItems(int limit) async {
    try {
      final allReturns = await localDataSource.getAllReturns();
      
      // تجميع حسب نوع القات
      final Map<int, List<ReturnItem>> groupedReturns = {};
      for (final returnItem in allReturns) {
        if (!groupedReturns.containsKey(returnItem.qatTypeId)) {
          groupedReturns[returnItem.qatTypeId] = [];
        }
        groupedReturns[returnItem.qatTypeId]!.add(returnItem);
      }

      // ترتيب حسب العدد
      final sortedEntries = groupedReturns.entries.toList()
        ..sort((a, b) => b.value.length.compareTo(a.value.length));

      // إرجاع أول عنصر من كل مجموعة
      return sortedEntries
          .take(limit)
          .map((entry) => entry.value.first)
          .toList();
    } catch (e) {
      throw Exception('فشل في الحصول على الأصناف الأكثر إرجاعاً: $e');
    }
  }

  @override
  Future<Map<String, int>> getReturnReasonAnalysis() async {
    try {
      return await localDataSource.getReturnReasonAnalysis();
    } catch (e) {
      throw Exception('فشل في تحليل أسباب المردود: $e');
    }
  }

  @override
  Future<List<ReturnItem>> getFrequentReturnCustomers(int limit) async {
    try {
      final salesReturns = await getSalesReturns();
      
      // تجميع حسب العميل
      final Map<int?, List<ReturnItem>> groupedReturns = {};
      for (final returnItem in salesReturns) {
        if (returnItem.customerId != null) {
          if (!groupedReturns.containsKey(returnItem.customerId)) {
            groupedReturns[returnItem.customerId] = [];
          }
          groupedReturns[returnItem.customerId]!.add(returnItem);
        }
      }

      // ترتيب حسب العدد
      final sortedEntries = groupedReturns.entries.toList()
        ..sort((a, b) => b.value.length.compareTo(a.value.length));

      return sortedEntries
          .take(limit)
          .map((entry) => entry.value.first)
          .toList();
    } catch (e) {
      throw Exception('فشل في الحصول على العملاء كثيري الإرجاع: $e');
    }
  }

  // ================= Helper Methods =================

  /// التحقق من صحة بيانات المردود
  void _validateReturnItem(ReturnItem returnItem) {
    if (returnItem.qatTypeId <= 0) {
      throw Exception('معرف نوع القات غير صحيح');
    }

    if (returnItem.unit.isEmpty) {
      throw Exception('الوحدة مطلوبة');
    }

    if (returnItem.quantity <= 0) {
      throw Exception('الكمية يجب أن تكون أكبر من صفر');
    }

    if (returnItem.unitPrice < 0) {
      throw Exception('سعر الوحدة يجب أن يكون موجباً');
    }

    if (returnItem.returnReason.trim().isEmpty) {
      throw Exception('سبب المردود مطلوب');
    }

    if (returnItem.isSalesReturn && returnItem.customerId == null) {
      throw Exception('معرف العميل مطلوب لمردود المبيعات');
    }

    if (returnItem.isPurchaseReturn && returnItem.supplierId == null) {
      throw Exception('معرف المورد مطلوب لمردود المشتريات');
    }
  }

  /// تحديث المخزون عند المردود
  Future<void> _updateInventoryForReturn(ReturnItem returnItem) async {
    if (inventoryRepository == null) return;

    try {
      if (returnItem.isSalesReturn) {
        // مردود مبيعات - إضافة للمخزون
        await inventoryRepository!.updateStockFromReturn(
          returnItem.qatTypeId,
          returnItem.unit,
          returnItem.quantity,
          'مردود مبيعات: ${returnItem.returnReason}',
          returnItem.returnNumber,
          returnItem.id ?? 0,
        );
      } else if (returnItem.isPurchaseReturn) {
        // مردود مشتريات - سحب من المخزون
        await inventoryRepository!.updateStockFromSale(
          returnItem.qatTypeId,
          returnItem.unit,
          returnItem.quantity,
          'RET-${returnItem.returnNumber}',
          returnItem.id ?? 0,
        );
      }
    } catch (e) {
      print('خطأ في تحديث المخزون للمردود: $e');
      // لا نلقي خطأ هنا لأن المردود نفسه تم بنجاح
    }
  }
}
