// ignore_for_file: public_member_api_docs

import '../../repositories/debt_repository.dart';
import '../base/base_usecase.dart';

class DeleteDebt implements UseCase<void, int> {
  final DebtRepository repo;
  DeleteDebt(this.repo);
  @override
  Future<void> call(int id) => repo.delete(id);
}
