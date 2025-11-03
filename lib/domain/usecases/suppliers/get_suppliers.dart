// ignore_for_file: public_member_api_docs

import '../../entities/supplier.dart';
import '../../repositories/supplier_repository.dart';
import '../base/base_usecase.dart';

/// حالة استخدام جلب قائمة الموردين
class GetSuppliers implements UseCase<List<Supplier>, GetSuppliersParams> {
  final SupplierRepository repo;
  
  GetSuppliers(this.repo);
  
  @override
  Future<List<Supplier>> call(GetSuppliersParams params) async {
    // جلب جميع الموردين
    List<Supplier> suppliers = await repo.getAll();
    
    // تطبيق الفلاتر إذا وجدت
    if (params.minRating != null) {
      suppliers = suppliers.where((s) => s.qualityRating >= params.minRating!).toList();
    }
    
    if (params.hasDebtOnly) {
      suppliers = suppliers.where((s) => s.hasDebt).toList();
    }
    
    // الفرز
    if (params.sortBy != null) {
      switch (params.sortBy) {
        case SupplierSortBy.name:
          suppliers.sort((a, b) => a.name.compareTo(b.name));
          break;
        case SupplierSortBy.rating:
          suppliers.sort((a, b) => b.qualityRating.compareTo(a.qualityRating));
          break;
        case SupplierSortBy.totalPurchases:
          suppliers.sort((a, b) => b.totalPurchases.compareTo(a.totalPurchases));
          break;
        default:
          break;
      }
    }
    
    return suppliers;
  }
}

/// معاملات جلب الموردين
class GetSuppliersParams {
  final int? minRating;
  final bool hasDebtOnly;
  final SupplierSortBy? sortBy;
  
  const GetSuppliersParams({
    this.minRating,
    this.hasDebtOnly = false,
    this.sortBy,
  });
}

/// أنواع الفرز للموردين
enum SupplierSortBy {
  name,
  rating,
  totalPurchases,
}
