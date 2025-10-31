// ignore_for_file: public_member_api_docs

import '../../entities/expense.dart';
import '../../repositories/expense_repository.dart';
import '../base/base_usecase.dart';

class GetExpensesByCategory implements UseCase<List<Expense>, String> {
  final ExpenseRepository repo;
  GetExpensesByCategory(this.repo);
  @override
  Future<List<Expense>> call(String category) => repo.getByCategory(category);
}
