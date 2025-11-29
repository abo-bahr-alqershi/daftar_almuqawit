// ignore_for_file: public_member_api_docs

import '../../entities/debt.dart';
import '../../repositories/debt_repository.dart';
import '../base/base_usecase.dart';

class GetCustomerDebts implements UseCase<List<Debt>, int> {
  final DebtRepository repo;
  GetCustomerDebts(this.repo);
  @override
  Future<List<Debt>> call(int customerId) =>
      repo.getByPerson('عميل', customerId);
}
