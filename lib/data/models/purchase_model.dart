// ignore_for_file: public_member_api_docs

import 'base/base_model.dart';
import '../database/tables/purchases_table.dart';

class PurchaseModel extends BaseModel {
  final int? id;
  final String date;
  final String time;
  final int? supplierId;
  final int? qatTypeId;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double totalAmount;
  final String paymentStatus;
  final double paidAmount;
  final double remainingAmount;
  final String? notes;

  const PurchaseModel({
    this.id,
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

  factory PurchaseModel.fromMap(Map<String, Object?> map) => PurchaseModel(
        id: map[PurchasesTable.cId] as int?,
        date: map[PurchasesTable.cDate] as String,
        time: map[PurchasesTable.cTime] as String,
        supplierId: map[PurchasesTable.cSupplierId] as int?,
        qatTypeId: map[PurchasesTable.cQatTypeId] as int?,
        quantity: (map[PurchasesTable.cQuantity] as num).toDouble(),
        unit: (map[PurchasesTable.cUnit] as String?) ?? 'ربطة',
        unitPrice: (map[PurchasesTable.cUnitPrice] as num).toDouble(),
        totalAmount: (map[PurchasesTable.cTotalAmount] as num).toDouble(),
        paymentStatus: (map[PurchasesTable.cPaymentStatus] as String?) ?? 'نقد',
        paidAmount: (map[PurchasesTable.cPaidAmount] as num?)?.toDouble() ?? 0,
        remainingAmount: (map[PurchasesTable.cRemainingAmount] as num?)?.toDouble() ?? 0,
        notes: map[PurchasesTable.cNotes] as String?,
      );

  @override
  Map<String, Object?> toMap() => {
        PurchasesTable.cId: id,
        PurchasesTable.cDate: date,
        PurchasesTable.cTime: time,
        PurchasesTable.cSupplierId: supplierId,
        PurchasesTable.cQatTypeId: qatTypeId,
        PurchasesTable.cQuantity: quantity,
        PurchasesTable.cUnit: unit,
        PurchasesTable.cUnitPrice: unitPrice,
        PurchasesTable.cTotalAmount: totalAmount,
        PurchasesTable.cPaymentStatus: paymentStatus,
        PurchasesTable.cPaidAmount: paidAmount,
        PurchasesTable.cRemainingAmount: remainingAmount,
        PurchasesTable.cNotes: notes,
      };
}
