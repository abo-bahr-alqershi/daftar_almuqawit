// ignore_for_file: public_member_api_docs

import 'base/base_entity.dart';

/// كيان دفعة دين
class DebtPayment extends BaseEntity {
  final int debtId;
  final double amount;
  final String paymentDate;
  final String paymentTime;
  final String paymentMethod; // نقد | تحويل
  final String? notes;

  const DebtPayment({
    super.id,
    required this.debtId,
    required this.amount,
    required this.paymentDate,
    required this.paymentTime,
    this.paymentMethod = 'نقد',
    this.notes,
  });
}
