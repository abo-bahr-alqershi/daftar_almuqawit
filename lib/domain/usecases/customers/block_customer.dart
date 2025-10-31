// ignore_for_file: public_member_api_docs

import '../../entities/customer.dart';
import '../../repositories/customer_repository.dart';
import '../base/base_usecase.dart';

class BlockCustomer implements UseCase<void, ({int id, bool isBlocked})> {
  final CustomerRepository repo;
  BlockCustomer(this.repo);
  @override
  Future<void> call(({int id, bool isBlocked}) params) async {
    final current = await repo.getById(params.id);
    if (current == null) return;
    final updated = Customer(
      id: current.id,
      name: current.name,
      phone: current.phone,
      nickname: current.nickname,
      customerType: current.customerType,
      creditLimit: current.creditLimit,
      totalPurchases: current.totalPurchases,
      currentDebt: current.currentDebt,
      isBlocked: params.isBlocked,
      notes: current.notes,
      createdAt: current.createdAt,
    );
    await repo.update(updated);
  }
}
