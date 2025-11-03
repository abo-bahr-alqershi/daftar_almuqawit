// ignore_for_file: public_member_api_docs

import '../../entities/supplier.dart';
import '../../repositories/supplier_repository.dart';
import '../base/base_usecase.dart';

/// حالة استخدام إضافة مورد جديد
class AddSupplier implements UseCase<int, Supplier> {
  final SupplierRepository repo;
  
  AddSupplier(this.repo);
  
  @override
  Future<int> call(Supplier params) async {
    // التحقق من صحة البيانات المدخلة
    if (!params.isValid()) {
      throw ArgumentError('بيانات المورد غير صحيحة');
    }
    
    // التحقق من عدم وجود مورد بنفس الاسم
    final existingSuppliers = await repo.searchByName(params.name);
    if (existingSuppliers.isNotEmpty) {
      // التحقق من التطابق التام
      final exactMatch = existingSuppliers.any(
        (s) => s.name.trim().toLowerCase() == params.name.trim().toLowerCase(),
      );
      if (exactMatch) {
        throw StateError('يوجد مورد بنفس الاسم بالفعل');
      }
    }
    
    // إضافة المورد
    return await repo.add(params);
  }
}
