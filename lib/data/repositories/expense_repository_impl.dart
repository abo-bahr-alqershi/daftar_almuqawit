// ignore_for_file: public_member_api_docs

import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/local/expense_local_datasource.dart';
import '../models/expense_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDataSource local;
  ExpenseRepositoryImpl(this.local);

  Expense _fromModel(ExpenseModel m) => Expense(
        id: m.id,
        date: m.date,
        time: m.time,
        category: m.category,
        amount: m.amount,
        description: m.description,
        paymentMethod: m.paymentMethod,
        recurring: m.recurring == 1,
        notes: m.notes,
      );

  ExpenseModel _toModel(Expense e) => ExpenseModel(
        id: e.id,
        date: e.date,
        time: e.time,
        category: e.category,
        amount: e.amount,
        description: e.description,
        paymentMethod: e.paymentMethod,
        recurring: e.recurring ? 1 : 0,
        notes: e.notes,
      );

  @override
  Future<int> add(Expense entity) => local.insert(_toModel(entity));

  @override
  Future<void> delete(int id) => local.delete(id);

  @override
  Future<List<Expense>> getAll() async => <Expense>[];

  @override
  Future<Expense?> getById(int id) async => null;

  @override
  Future<List<Expense>> getByCategory(String category) async {
    final models = await local.getByCategory(category);
    return models.map(_fromModel).toList();
  }
  
  @override
  Future<List<Expense>> getByDate(String date) async {
    final models = await local.getByDate(date);
    return models.map(_fromModel).toList();
  }

  @override
  Future<List<Expense>> getDaily(String date) async {
    final models = await local.getDaily(date);
    return models.map(_fromModel).toList();
  }

  @override
  Future<void> update(Expense entity) => local.update(_toModel(entity));
}
