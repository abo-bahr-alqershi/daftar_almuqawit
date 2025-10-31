// ignore_for_file: public_member_api_docs

import 'base/base_model.dart';
import '../database/tables/expenses_table.dart';

class ExpenseModel extends BaseModel {
  final int? id;
  final String date;
  final String time;
  final String category;
  final double amount;
  final String? description;
  final String paymentMethod;
  final int recurring;
  final String? notes;

  const ExpenseModel({
    this.id,
    required this.date,
    required this.time,
    required this.category,
    required this.amount,
    this.description,
    this.paymentMethod = 'نقد',
    this.recurring = 0,
    this.notes,
  });

  factory ExpenseModel.fromMap(Map<String, Object?> map) => ExpenseModel(
        id: map[ExpensesTable.cId] as int?,
        date: map[ExpensesTable.cDate] as String,
        time: map[ExpensesTable.cTime] as String,
        category: map[ExpensesTable.cCategory] as String,
        amount: (map[ExpensesTable.cAmount] as num).toDouble(),
        description: map[ExpensesTable.cDescription] as String?,
        paymentMethod: (map[ExpensesTable.cPaymentMethod] as String?) ?? 'نقد',
        recurring: (map[ExpensesTable.cRecurring] as int?) ?? 0,
        notes: map[ExpensesTable.cNotes] as String?,
      );

  @override
  Map<String, Object?> toMap() => {
        ExpensesTable.cId: id,
        ExpensesTable.cDate: date,
        ExpensesTable.cTime: time,
        ExpensesTable.cCategory: category,
        ExpensesTable.cAmount: amount,
        ExpensesTable.cDescription: description,
        ExpensesTable.cPaymentMethod: paymentMethod,
        ExpensesTable.cRecurring: recurring,
        ExpensesTable.cNotes: notes,
      };
}
