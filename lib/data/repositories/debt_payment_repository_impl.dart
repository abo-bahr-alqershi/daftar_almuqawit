// ignore_for_file: public_member_api_docs

import '../../domain/entities/debt_payment.dart';
import '../../domain/repositories/debt_payment_repository.dart';
import '../datasources/local/debt_payment_local_datasource.dart';
import '../models/debt_payment_model.dart';

class DebtPaymentRepositoryImpl implements DebtPaymentRepository {
  final DebtPaymentLocalDataSource local;
  DebtPaymentRepositoryImpl(this.local);

  DebtPayment _fromModel(DebtPaymentModel m) => DebtPayment(
        id: m.id,
        debtId: m.debtId,
        amount: m.amount,
        paymentDate: m.paymentDate,
        paymentTime: m.paymentTime,
        paymentMethod: m.paymentMethod,
        notes: m.notes,
      );

  DebtPaymentModel _toModel(DebtPayment e) => DebtPaymentModel(
        id: e.id,
        debtId: e.debtId,
        amount: e.amount,
        paymentDate: e.paymentDate,
        paymentTime: e.paymentTime,
        paymentMethod: e.paymentMethod,
        notes: e.notes,
      );

  @override
  Future<int> add(DebtPayment entity) => local.insert(_toModel(entity));

  @override
  Future<void> delete(int id) async {
    // ليس لدينا delete مباشر لدفعات الديون حالياً
  }

  @override
  Future<List<DebtPayment>> getAll() async => <DebtPayment>[];

  @override
  Future<DebtPayment?> getById(int id) async => null;

  @override
  Future<List<DebtPayment>> getByDebt(int debtId) async => (await local.getByDebt(debtId)).map(_fromModel).toList();

  @override
  Future<void> update(DebtPayment entity) async {
    // ليس لدينا update مباشر لدفعات الديون حالياً
  }
}
