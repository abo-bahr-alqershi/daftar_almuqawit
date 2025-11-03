// ignore_for_file: public_member_api_docs

import '../../domain/entities/supplier.dart';
import '../../domain/repositories/supplier_repository.dart';
import '../datasources/local/supplier_local_datasource.dart';
import '../models/supplier_model.dart';

/// تطبيق مستودع الموردين يربط الدومين بالبيانات المحلية
class SupplierRepositoryImpl implements SupplierRepository {
  final SupplierLocalDataSource local;
  SupplierRepositoryImpl(this.local);

  Supplier _fromModel(SupplierModel m) => Supplier(
        id: m.id,
        name: m.name,
        phone: m.phone,
        area: m.area,
        qualityRating: m.qualityRating,
        trustLevel: m.trustLevel,
        totalPurchases: m.totalPurchases,
        totalDebtToHim: m.totalDebtToHim,
        notes: m.notes,
        createdAt: m.createdAt?.toIso8601String(),
      );

  SupplierModel _toModel(Supplier e) => SupplierModel(
        id: e.id,
        name: e.name,
        phone: e.phone,
        area: e.area,
        qualityRating: e.qualityRating,
        trustLevel: e.trustLevel,
        totalPurchases: e.totalPurchases,
        totalDebtToHim: e.totalDebtToHim,
        notes: e.notes,
        createdAt: e.createdAt != null ? DateTime.tryParse(e.createdAt!) : null,
      );

  @override
  Future<int> add(Supplier entity) => local.insert(_toModel(entity));

  @override
  Future<void> delete(int id) => local.delete(id);

  @override
  Future<List<Supplier>> getAll() async {
    final list = await local.getAll();
    return list.map(_fromModel).toList();
  }

  @override
  Future<Supplier?> getById(int id) async {
    final m = await local.getById(id);
    return m == null ? null : _fromModel(m);
  }

  @override
  Future<List<Supplier>> searchByName(String query) async {
    final list = await local.searchByName(query);
    return list.map(_fromModel).toList();
  }

  @override
  Future<void> update(Supplier entity) => local.update(_toModel(entity));

  @override
  Future<List<Supplier>> searchByPhone(String phone) async {
    final list = await local.searchByPhone(phone);
    return list.map(_fromModel).toList();
  }

  @override
  Future<List<Supplier>> searchByArea(String area) async {
    final list = await local.searchByArea(area);
    return list.map(_fromModel).toList();
  }

  @override
  Future<List<Supplier>> filterByRating(int minRating) async {
    final allSuppliers = await getAll();
    return allSuppliers.where((s) => s.qualityRating >= minRating).toList();
  }

  @override
  Future<List<Supplier>> getSuppliersWithDebts() async {
    final allSuppliers = await getAll();
    return allSuppliers.where((s) => s.hasDebt).toList();
  }

  @override
  Future<List<Supplier>> getTopSuppliers({int limit = 10}) async {
    final allSuppliers = await getAll();
    allSuppliers.sort((a, b) {
      final ratingCompare = b.qualityRating.compareTo(a.qualityRating);
      if (ratingCompare != 0) return ratingCompare;
      return b.totalPurchases.compareTo(a.totalPurchases);
    });
    return allSuppliers.take(limit).toList();
  }

  @override
  Future<void> syncSupplier(Supplier supplier) async {
    // TODO: تنفيذ المزامنة مع السحابة
    // سيتم تنفيذها لاحقاً عند إضافة remote datasource
  }

  @override
  Future<void> syncAll() async {
    // TODO: تنفيذ مزامنة جميع الموردين
    // سيتم تنفيذها لاحقاً عند إضافة remote datasource
  }

  @override
  Future<Map<String, dynamic>> getStatistics() async {
    final allSuppliers = await getAll();
    return {
      'total': allSuppliers.length,
      'withDebts': allSuppliers.where((s) => s.hasDebt).length,
      'averageRating': allSuppliers.isEmpty
          ? 0.0
          : allSuppliers.map((s) => s.qualityRating).reduce((a, b) => a + b) /
              allSuppliers.length,
      'totalPurchases': allSuppliers.fold<double>(
          0, (sum, s) => sum + s.totalPurchases),
      'totalDebts':
          allSuppliers.fold<double>(0, (sum, s) => sum + s.totalDebtToHim),
    };
  }
}
