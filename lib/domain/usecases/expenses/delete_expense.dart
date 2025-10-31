// ignore_for_file: public_member_api_docs

import '../../repositories/expense_repository.dart';
import '../base/base_usecase.dart';

class DeleteExpense implements UseCase<void, int> {
  final ExpenseRepository repo;
  DeleteExpense(this.repo);
  @override
  Future<void> call(int id) => repo.delete(id);
}
