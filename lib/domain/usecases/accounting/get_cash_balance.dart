// ignore_for_file: public_member_api_docs

import '../../repositories/accounting_repository.dart';
import '../base/base_usecase.dart';

class GetCashBalance implements UseCase<double, NoParams> {
  final AccountingRepository repo;
  GetCashBalance(this.repo);
  @override
  Future<double> call(NoParams params) => repo.getCashBalance();
}
