// ignore_for_file: public_member_api_docs

import '../../entities/debt.dart';
import '../../repositories/debt_repository.dart';
import '../base/base_usecase.dart';

class AddDebt implements UseCase<int, Debt> {
  final DebtRepository repo;
  AddDebt(this.repo);
  @override
  Future<int> call(Debt params) => repo.add(params);
}
