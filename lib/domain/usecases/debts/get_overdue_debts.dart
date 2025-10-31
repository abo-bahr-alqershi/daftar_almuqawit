// ignore_for_file: public_member_api_docs

import '../../entities/debt.dart';
import '../../repositories/debt_repository.dart';
import '../base/base_usecase.dart';

class GetOverdueDebts implements UseCase<List<Debt>, String> {
  final DebtRepository repo;
  GetOverdueDebts(this.repo);
  @override
  Future<List<Debt>> call(String today) => repo.getOverdue(today);
}
