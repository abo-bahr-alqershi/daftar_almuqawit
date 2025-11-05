// ignore_for_file: public_member_api_docs

import 'base/base_entity.dart';

/// كيان عملية شراء
class Purchase extends BaseEntity {
  final String date;
  final String time;
  final int? supplierId;
  final int? qatTypeId;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double totalAmount;
  final String paymentStatus; // نقد، آجل، جزئي
  final double paidAmount;
  final double remainingAmount;
  final String? notes;

  const Purchase({
    super.id,
    required this.date,
    required this.time,
    this.supplierId,
    this.qatTypeId,
    required this.quantity,
    this.unit = 'ربطة',
    required this.unitPrice,
    required this.totalAmount,
    this.paymentStatus = 'نقد',
    this.paidAmount = 0,
    this.remainingAmount = 0,
    this.notes,
  });
  
  /// تحويل الشراء إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'time': time,
      'supplier_id': supplierId,
      'qat_type_id': qatTypeId,
      'quantity': quantity,
      'unit': unit,
      'unit_price': unitPrice,
      'total_amount': totalAmount,
      'payment_status': paymentStatus,
      'paid_amount': paidAmount,
      'remaining_amount': remainingAmount,
      'notes': notes,
    };
  }
}
