// ignore_for_file: public_member_api_docs

import '../../entities/debt_payment.dart';
import '../../repositories/debt_payment_repository.dart';
import '../base/base_usecase.dart';

class UpdateDebtPayment implements UseCase<void, DebtPayment> {
  final DebtPaymentRepository repository;

  UpdateDebtPayment(this.repository);

  @override
  Future<void> call(DebtPayment params) async {
    await repository.update(params);
  }
}
