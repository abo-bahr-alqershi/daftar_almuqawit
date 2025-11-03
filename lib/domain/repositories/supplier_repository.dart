// ignore_for_file: public_member_api_docs

import '../entities/supplier.dart';
import 'base/base_repository.dart';

/// عقد مستودع الموردين
abstract class SupplierRepository extends BaseRepository<Supplier> {
  /// البحث عن موردين بالاسم
  Future<List<Supplier>> searchByName(String query);
  
  /// البحث عن موردين برقم الهاتف
  Future<List<Supplier>> searchByPhone(String phone);
  
  /// البحث عن موردين بالمنطقة
  Future<List<Supplier>> searchByArea(String area);
  
  /// فلترة الموردين حسب التقييم
  Future<List<Supplier>> filterByRating(int minRating);
  
  /// الحصول على الموردين الذين لهم ديون
  Future<List<Supplier>> getSuppliersWithDebts();
  
  /// الحصول على أفضل الموردين (حسب التقييم والمشتريات)
  Future<List<Supplier>> getTopSuppliers({int limit = 10});
  
  /// مزامنة مورد مع السحابة
  Future<void> syncSupplier(Supplier supplier);
  
  /// مزامنة جميع الموردين
  Future<void> syncAll();
  
  /// الحصول على إحصائيات الموردين
  Future<Map<String, dynamic>> getStatistics();
}
