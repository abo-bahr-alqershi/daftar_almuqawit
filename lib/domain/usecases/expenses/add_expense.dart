// ignore_for_file: public_member_api_docs

import '../../entities/expense.dart';
import '../../repositories/expense_repository.dart';
import '../base/base_usecase.dart';

class AddExpense implements UseCase<int, Expense> {
  final ExpenseRepository repo;
  AddExpense(this.repo);
  @override
  Future<int> call(Expense params) => repo.add(params);
}
