// ignore_for_file: public_member_api_docs

import '../../entities/expense.dart';
import '../../repositories/expense_repository.dart';
import '../base/base_usecase.dart';

class UpdateExpense implements UseCase<void, Expense> {
  final ExpenseRepository repo;
  UpdateExpense(this.repo);
  @override
  Future<void> call(Expense params) => repo.update(params);
}
