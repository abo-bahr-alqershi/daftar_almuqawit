import '../../entities/return_item.dart';
import '../../repositories/returns_repository.dart';
import '../base/base_usecase.dart';

/// حالة استخدام الحصول على قائمة المردودات
class GetReturnsList implements UseCase<List<ReturnItem>, GetReturnsListParams> {
  final ReturnsRepository repository;

  GetReturnsList(this.repository);

  @override
  Future<List<ReturnItem>> call(GetReturnsListParams params) async {
    try {
      switch (params.filterType) {
        case ReturnsFilterType.all:
          return await repository.getAllReturns();
        
        case ReturnsFilterType.salesReturns:
          return await repository.getSalesReturns();
        
        case ReturnsFilterType.purchaseReturns:
          return await repository.getPurchaseReturns();
        
        case ReturnsFilterType.pending:
          return await repository.getPendingReturns();
        
        case ReturnsFilterType.confirmed:
          return await repository.getConfirmedReturns();
        
        case ReturnsFilterType.byCustomer:
          if (params.customerId == null) {
            throw Exception('معرف العميل مطلوب');
          }
          return await repository.getReturnsByCustomer(params.customerId!);
        
        case ReturnsFilterType.bySupplier:
          if (params.supplierId == null) {
            throw Exception('معرف المورد مطلوب');
          }
          return await repository.getReturnsBySupplier(params.supplierId!);
        
        case ReturnsFilterType.byDateRange:
          if (params.startDate == null || params.endDate == null) {
            throw Exception('تواريخ البداية والنهاية مطلوبة');
          }
          return await repository.getReturnsByDateRange(params.startDate!, params.endDate!);
        
        case ReturnsFilterType.byQatType:
          if (params.qatTypeId == null) {
            throw Exception('معرف نوع القات مطلوب');
          }
          return await repository.getReturnsByQatType(params.qatTypeId!);
        
        case ReturnsFilterType.search:
          if (params.searchQuery == null || params.searchQuery!.trim().isEmpty) {
            return await repository.getAllReturns();
          }
          return await repository.searchReturns(params.searchQuery!.trim());
        
        default:
          return await repository.getAllReturns();
      }
    } catch (e) {
      throw Exception('فشل في الحصول على قائمة المردودات: $e');
    }
  }
}

/// أنواع تصفية المردودات
enum ReturnsFilterType {
  all,
  salesReturns,
  purchaseReturns,
  pending,
  confirmed,
  byCustomer,
  bySupplier,
  byDateRange,
  byQatType,
  search,
}

/// معاملات الحصول على قائمة المردودات
class GetReturnsListParams {
  final ReturnsFilterType filterType;
  final int? customerId;
  final int? supplierId;
  final int? qatTypeId;
  final String? startDate;
  final String? endDate;
  final String? searchQuery;

  const GetReturnsListParams({
    this.filterType = ReturnsFilterType.all,
    this.customerId,
    this.supplierId,
    this.qatTypeId,
    this.startDate,
    this.endDate,
    this.searchQuery,
  });
}
