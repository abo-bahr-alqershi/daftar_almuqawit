// ignore_for_file: public_member_api_docs

import 'base/base_model.dart';
import '../database/tables/debts_table.dart';

class DebtModel extends BaseModel {
  final int? id;
  final String personType;
  final int personId;
  final String personName;
  final String? transactionType;
  final int? transactionId;
  final double originalAmount;
  final double paidAmount;
  final double remainingAmount;
  final String date;
  final String? dueDate;
  final String status;
  final String? lastPaymentDate;
  final String? notes;

  const DebtModel({
    this.id,
    required this.personType,
    required this.personId,
    required this.personName,
    this.transactionType,
    this.transactionId,
    required this.originalAmount,
    this.paidAmount = 0,
    required this.remainingAmount,
    required this.date,
    this.dueDate,
    this.status = 'غير مسدد',
    this.lastPaymentDate,
    this.notes,
  });

  factory DebtModel.fromMap(Map<String, Object?> map) => DebtModel(
        id: map[DebtsTable.cId] as int?,
        personType: map[DebtsTable.cPersonType] as String,
        personId: map[DebtsTable.cPersonId] as int,
        personName: map[DebtsTable.cPersonName] as String,
        transactionType: map[DebtsTable.cTransactionType] as String?,
        transactionId: map[DebtsTable.cTransactionId] as int?,
        originalAmount: (map[DebtsTable.cOriginalAmount] as num).toDouble(),
        paidAmount: (map[DebtsTable.cPaidAmount] as num?)?.toDouble() ?? 0,
        remainingAmount: (map[DebtsTable.cRemainingAmount] as num).toDouble(),
        date: map[DebtsTable.cDate] as String,
        dueDate: map[DebtsTable.cDueDate] as String?,
        status: (map[DebtsTable.cStatus] as String?) ?? 'غير مسدد',
        lastPaymentDate: map[DebtsTable.cLastPaymentDate] as String?,
        notes: map[DebtsTable.cNotes] as String?,
      );

  @override
  Map<String, Object?> toMap() => {
        DebtsTable.cId: id,
        DebtsTable.cPersonType: personType,
        DebtsTable.cPersonId: personId,
        DebtsTable.cPersonName: personName,
        DebtsTable.cTransactionType: transactionType,
        DebtsTable.cTransactionId: transactionId,
        DebtsTable.cOriginalAmount: originalAmount,
        DebtsTable.cPaidAmount: paidAmount,
        DebtsTable.cRemainingAmount: remainingAmount,
        DebtsTable.cDate: date,
        DebtsTable.cDueDate: dueDate,
        DebtsTable.cStatus: status,
        DebtsTable.cLastPaymentDate: lastPaymentDate,
        DebtsTable.cNotes: notes,
      };
}
