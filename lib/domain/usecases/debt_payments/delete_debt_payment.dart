// ignore_for_file: public_member_api_docs

import '../../repositories/debt_payment_repository.dart';
import '../base/base_usecase.dart';

class DeleteDebtPayment implements UseCase<void, int> {
  final DebtPaymentRepository repository;

  DeleteDebtPayment(this.repository);

  @override
  Future<void> call(int params) async {
    await repository.delete(params);
  }
}
