// ignore_for_file: public_member_api_docs

import '../../entities/debt.dart';
import '../../repositories/debt_repository.dart';
import '../base/base_usecase.dart';

class GetPendingDebts implements UseCase<List<Debt>, NoParams> {
  final DebtRepository repo;
  GetPendingDebts(this.repo);
  @override
  Future<List<Debt>> call(NoParams params) => repo.getPending();
}
