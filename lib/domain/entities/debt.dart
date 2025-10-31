// ignore_for_file: public_member_api_docs

import 'base/base_entity.dart';

/// كيان الدين
class Debt extends BaseEntity {
  final String personType; // عميل | مورد
  final int personId;
  final String personName;
  final String? transactionType; // بيع | شراء
  final int? transactionId;
  final double originalAmount;
  final double paidAmount;
  final double remainingAmount;
  final String date;
  final String? dueDate;
  final String status; // مسدد | مسدد جزئي | غير مسدد
  final String? lastPaymentDate;
  final String? notes;

  const Debt({
    super.id,
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
}
