// ignore_for_file: public_member_api_docs

import '../../domain/entities/debt.dart';
import '../../domain/repositories/debt_repository.dart';
import '../datasources/local/debt_local_datasource.dart';
import '../models/debt_model.dart';

class DebtRepositoryImpl implements DebtRepository {
  final DebtLocalDataSource local;
  DebtRepositoryImpl(this.local);

  Debt _fromModel(DebtModel m) => Debt(
        id: m.id,
        personType: m.personType,
        personId: m.personId,
        personName: m.personName,
        transactionType: m.transactionType,
        transactionId: m.transactionId,
        originalAmount: m.originalAmount,
        paidAmount: m.paidAmount,
        remainingAmount: m.remainingAmount,
        date: m.date,
        dueDate: m.dueDate,
        status: m.status,
        lastPaymentDate: m.lastPaymentDate,
        notes: m.notes,
      );

  DebtModel _toModel(Debt e) => DebtModel(
        id: e.id,
        personType: e.personType,
        personId: e.personId,
        personName: e.personName,
        transactionType: e.transactionType,
        transactionId: e.transactionId,
        originalAmount: e.originalAmount,
        paidAmount: e.paidAmount,
        remainingAmount: e.remainingAmount,
        date: e.date,
        dueDate: e.dueDate,
        status: e.status,
        lastPaymentDate: e.lastPaymentDate,
        notes: e.notes,
      );

  @override
  Future<int> add(Debt entity) => local.insert(_toModel(entity));

  @override
  Future<void> delete(int id) => local.delete(id);

  @override
  Future<List<Debt>> getAll() async => (await local.getAll()).map(_fromModel).toList();

  @override
  Future<Debt?> getById(int id) async {
    final m = await local.getById(id);
    return m == null ? null : _fromModel(m);
  }

  @override
  Future<List<Debt>> getOverdue(String today) async => (await local.getOverdue(today)).map(_fromModel).toList();

  @override
  Future<List<Debt>> getPending() async => (await local.getPending()).map(_fromModel).toList();

  @override
  Future<List<Debt>> getByPerson(String personType, int personId) async =>
      (await local.getByPerson(personType, personId)).map(_fromModel).toList();

  @override
  Future<void> update(Debt entity) => local.update(_toModel(entity));
}
