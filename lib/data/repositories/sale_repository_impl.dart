// ignore_for_file: public_member_api_docs

import '../../domain/entities/sale.dart';
import '../../domain/repositories/sales_repository.dart';
import '../datasources/local/sales_local_datasource.dart';
import '../models/sale_model.dart';

class SaleRepositoryImpl implements SalesRepository {
  final SalesLocalDataSource local;
  SaleRepositoryImpl(this.local);

  Sale _fromModel(SaleModel m) => Sale(
        id: m.id,
        date: m.date,
        time: m.time,
        customerId: m.customerId,
        qatTypeId: m.qatTypeId,
        quantity: m.quantity,
        unit: m.unit,
        unitPrice: m.unitPrice,
        totalAmount: m.totalAmount,
        paymentStatus: m.paymentStatus,
        paidAmount: m.paidAmount,
        remainingAmount: m.remainingAmount,
        profit: m.profit,
        notes: m.notes,
      );

  SaleModel _toModel(Sale e) => SaleModel(
        id: e.id,
        date: e.date,
        time: e.time,
        customerId: e.customerId,
        qatTypeId: e.qatTypeId,
        quantity: e.quantity,
        unit: e.unit,
        unitPrice: e.unitPrice,
        totalAmount: e.totalAmount,
        paymentStatus: e.paymentStatus,
        paidAmount: e.paidAmount,
        remainingAmount: e.remainingAmount,
        profit: e.profit,
        notes: e.notes,
      );

  @override
  Future<int> add(Sale entity) => local.insert(_toModel(entity));

  @override
  Future<void> delete(int id) => local.delete(id);

  @override
  Future<List<Sale>> getAll() async => (await local.getAll()).map(_fromModel).toList();

  @override
  Future<Sale?> getById(int id) async {
    final m = await local.getById(id);
    return m == null ? null : _fromModel(m);
  }

  @override
  Future<List<Sale>> getByCustomer(int customerId) async => (await local.getByCustomer(customerId)).map(_fromModel).toList();

  @override
  Future<List<Sale>> getTodaySales(String date) async => (await local.getToday(date)).map(_fromModel).toList();

  @override
  Future<void> update(Sale entity) => local.update(_toModel(entity));
}
