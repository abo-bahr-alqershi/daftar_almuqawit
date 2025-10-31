// ignore_for_file: public_member_api_docs

import '../../entities/debt_payment.dart';
import '../../repositories/debt_payment_repository.dart';
import '../base/base_usecase.dart';

class PartialPayment implements UseCase<int, DebtPayment> {
  final DebtPaymentRepository repo;
  PartialPayment(this.repo);
  @override
  Future<int> call(DebtPayment params) => repo.add(params);
}
