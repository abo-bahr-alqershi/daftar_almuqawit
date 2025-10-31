// ignore_for_file: public_member_api_docs

import '../entities/debt_payment.dart';
import 'base/base_repository.dart';

abstract class DebtPaymentRepository extends BaseRepository<DebtPayment> {
  Future<List<DebtPayment>> getByDebt(int debtId);
}
