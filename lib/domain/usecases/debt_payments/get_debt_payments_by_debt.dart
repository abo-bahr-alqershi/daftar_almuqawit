// ignore_for_file: public_member_api_docs

import '../../entities/debt_payment.dart';
import '../../repositories/debt_payment_repository.dart';
import '../base/base_usecase.dart';

class GetDebtPaymentsByDebt implements UseCase<List<DebtPayment>, int> {
  final DebtPaymentRepository repo;
  GetDebtPaymentsByDebt(this.repo);
  @override
  Future<List<DebtPayment>> call(int debtId) => repo.getByDebt(debtId);
}
