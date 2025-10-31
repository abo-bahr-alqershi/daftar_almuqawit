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
        createdAt: m.createdAt,
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
        createdAt: e.createdAt,
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
}
