// ignore_for_file: public_member_api_docs

import 'base/base_model.dart';
import '../database/tables/debt_payments_table.dart';

class DebtPaymentModel extends BaseModel {
  final int? id;
  final int debtId;
  final double amount;
  final String paymentDate;
  final String paymentTime;
  final String paymentMethod;
  final String? notes;

  const DebtPaymentModel({
    this.id,
    required this.debtId,
    required this.amount,
    required this.paymentDate,
    required this.paymentTime,
    this.paymentMethod = 'نقد',
    this.notes,
  });

  factory DebtPaymentModel.fromMap(Map<String, Object?> map) => DebtPaymentModel(
        id: map[DebtPaymentsTable.cId] as int?,
        debtId: map[DebtPaymentsTable.cDebtId] as int,
        amount: (map[DebtPaymentsTable.cAmount] as num).toDouble(),
        paymentDate: map[DebtPaymentsTable.cPaymentDate] as String,
        paymentTime: map[DebtPaymentsTable.cPaymentTime] as String,
        paymentMethod: (map[DebtPaymentsTable.cPaymentMethod] as String?) ?? 'نقد',
        notes: map[DebtPaymentsTable.cNotes] as String?,
      );

  @override
  Map<String, Object?> toMap() => {
        DebtPaymentsTable.cId: id,
        DebtPaymentsTable.cDebtId: debtId,
        DebtPaymentsTable.cAmount: amount,
        DebtPaymentsTable.cPaymentDate: paymentDate,
        DebtPaymentsTable.cPaymentTime: paymentTime,
        DebtPaymentsTable.cPaymentMethod: paymentMethod,
        DebtPaymentsTable.cNotes: notes,
      };
}
