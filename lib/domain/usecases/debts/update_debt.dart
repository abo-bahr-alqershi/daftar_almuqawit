// ignore_for_file: public_member_api_docs

import '../../entities/debt.dart';
import '../../repositories/debt_repository.dart';
import '../base/base_usecase.dart';

class UpdateDebt implements UseCase<void, Debt> {
  final DebtRepository repo;
  UpdateDebt(this.repo);
  @override
  Future<void> call(Debt params) => repo.update(params);
}
