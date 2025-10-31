// ignore_for_file: public_member_api_docs

import 'base/base_entity.dart';

/// كيان المصروف
class Expense extends BaseEntity {
  final String date;
  final String time;
  final String category; // إيجار، نقل، ...
  final double amount;
  final String? description;
  final String paymentMethod;
  final bool recurring;
  final String? notes;

  const Expense({
    super.id,
    required this.date,
    required this.time,
    required this.category,
    required this.amount,
    this.description,
    this.paymentMethod = 'نقد',
    this.recurring = false,
    this.notes,
  });
}
