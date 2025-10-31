// ignore_for_file: public_member_api_docs

import 'base/base_entity.dart';

/// كيان عملية بيع
class Sale extends BaseEntity {
  final String date;
  final String time;
  final int? customerId;
  final int? qatTypeId;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double totalAmount;
  final String paymentStatus;
  final double paidAmount;
  final double remainingAmount;
  final double? profit;
  final String? notes;

  const Sale({
    super.id,
    required this.date,
    required this.time,
    this.customerId,
    this.qatTypeId,
    required this.quantity,
    this.unit = 'ربطة',
    required this.unitPrice,
    required this.totalAmount,
    this.paymentStatus = 'نقد',
    this.paidAmount = 0,
    this.remainingAmount = 0,
    this.profit,
    this.notes,
  });
}
