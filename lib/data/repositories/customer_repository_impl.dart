// ignore_for_file: public_member_api_docs

import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/local/customer_local_datasource.dart';
import '../models/customer_model.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerLocalDataSource local;
  CustomerRepositoryImpl(this.local);

  Customer _fromModel(CustomerModel m) => Customer(
        id: m.id,
        name: m.name,
        phone: m.phone,
        nickname: m.nickname,
        customerType: m.customerType,
        creditLimit: m.creditLimit,
        totalPurchases: m.totalPurchases,
        currentDebt: m.currentDebt,
        isBlocked: m.isBlocked == 1,
        notes: m.notes,
        createdAt: m.createdAt,
      );

  CustomerModel _toModel(Customer e) => CustomerModel(
        id: e.id,
        name: e.name,
        phone: e.phone,
        nickname: e.nickname,
        customerType: e.customerType,
        creditLimit: e.creditLimit,
        totalPurchases: e.totalPurchases,
        currentDebt: e.currentDebt,
        isBlocked: e.isBlocked ? 1 : 0,
        notes: e.notes,
        createdAt: e.createdAt,
      );

  @override
  Future<int> add(Customer entity) => local.insert(_toModel(entity));

  @override
  Future<void> delete(int id) => local.delete(id);

  @override
  Future<List<Customer>> getAll() async => (await local.getAll()).map(_fromModel).toList();

  @override
  Future<Customer?> getById(int id) async {
    final m = await local.getById(id);
    return m == null ? null : _fromModel(m);
  }

  @override
  Future<List<Customer>> getBlocked() async => (await local.getBlocked()).map(_fromModel).toList();

  @override
  Future<List<Customer>> searchByName(String query) async => (await local.searchByName(query)).map(_fromModel).toList();

  @override
  Future<void> update(Customer entity) => local.update(_toModel(entity));
}
