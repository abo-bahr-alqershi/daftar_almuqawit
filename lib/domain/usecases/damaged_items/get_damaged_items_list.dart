import '../../entities/damaged_item.dart';
import '../../repositories/damaged_items_repository.dart';
import '../base/base_usecase.dart';

/// حالة استخدام الحصول على قائمة البضاعة التالفة
class GetDamagedItemsList implements UseCase<List<DamagedItem>, GetDamagedItemsListParams> {
  final DamagedItemsRepository repository;

  GetDamagedItemsList(this.repository);

  @override
  Future<List<DamagedItem>> call(GetDamagedItemsListParams params) async {
    try {
      switch (params.filterType) {
        case DamagedItemsFilterType.all:
          return await repository.getAllDamagedItems();
        
        case DamagedItemsFilterType.byType:
          if (params.damageType == null) {
            throw Exception('نوع التلف مطلوب');
          }
          return await repository.getDamagedItemsByType(params.damageType!);
        
        case DamagedItemsFilterType.bySeverity:
          if (params.severityLevel == null) {
            throw Exception('مستوى الخطورة مطلوب');
          }
          return await repository.getDamagedItemsBySeverity(params.severityLevel!);
        
        case DamagedItemsFilterType.byStatus:
          if (params.status == null) {
            throw Exception('الحالة مطلوبة');
          }
          return await repository.getDamagedItemsByStatus(params.status!);
        
        case DamagedItemsFilterType.critical:
          return await repository.getCriticalDamagedItems();
        
        case DamagedItemsFilterType.pending:
          return await repository.getPendingDamagedItems();
        
        case DamagedItemsFilterType.confirmed:
          return await repository.getConfirmedDamagedItems();
        
        case DamagedItemsFilterType.handled:
          return await repository.getHandledDamagedItems();
        
        case DamagedItemsFilterType.byWarehouse:
          if (params.warehouseId == null) {
            throw Exception('معرف المخزن مطلوب');
          }
          return await repository.getDamagedItemsByWarehouse(params.warehouseId!);
        
        case DamagedItemsFilterType.expired:
          return await repository.getExpiredItems();
        
        case DamagedItemsFilterType.expiringInDays:
          final days = params.daysToExpiry ?? 30;
          return await repository.getItemsExpiringInDays(days);
        
        case DamagedItemsFilterType.insuranceCovered:
          return await repository.getInsuranceCoveredItems();
        
        case DamagedItemsFilterType.byDateRange:
          if (params.startDate == null || params.endDate == null) {
            throw Exception('تواريخ البداية والنهاية مطلوبة');
          }
          return await repository.getDamagedItemsByDateRange(params.startDate!, params.endDate!);
        
        case DamagedItemsFilterType.search:
          if (params.searchQuery == null || params.searchQuery!.trim().isEmpty) {
            return await repository.getAllDamagedItems();
          }
          return await repository.searchDamagedItems(params.searchQuery!.trim());
        
        default:
          return await repository.getAllDamagedItems();
      }
    } catch (e) {
      throw Exception('فشل في الحصول على قائمة البضاعة التالفة: $e');
    }
  }
}

/// أنواع تصفية البضاعة التالفة
enum DamagedItemsFilterType {
  all,
  byType,
  bySeverity,
  byStatus,
  critical,
  pending,
  confirmed,
  handled,
  byWarehouse,
  expired,
  expiringInDays,
  insuranceCovered,
  byDateRange,
  search,
}

/// معاملات الحصول على قائمة البضاعة التالفة
class GetDamagedItemsListParams {
  final DamagedItemsFilterType filterType;
  final String? damageType;
  final String? severityLevel;
  final String? status;
  final int? warehouseId;
  final int? daysToExpiry;
  final String? startDate;
  final String? endDate;
  final String? searchQuery;

  const GetDamagedItemsListParams({
    this.filterType = DamagedItemsFilterType.all,
    this.damageType,
    this.severityLevel,
    this.status,
    this.warehouseId,
    this.daysToExpiry,
    this.startDate,
    this.endDate,
    this.searchQuery,
  });
}
