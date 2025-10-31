// ignore_for_file: public_member_api_docs

import 'base/base_model.dart';
import '../database/tables/sales_table.dart';

class SaleModel extends BaseModel {
  final int? id;
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

  const SaleModel({
    this.id,
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

  factory SaleModel.fromMap(Map<String, Object?> map) => SaleModel(
        id: map[SalesTable.cId] as int?,
        date: map[SalesTable.cDate] as String,
        time: map[SalesTable.cTime] as String,
        customerId: map[SalesTable.cCustomerId] as int?,
        qatTypeId: map[SalesTable.cQatTypeId] as int?,
        quantity: (map[SalesTable.cQuantity] as num).toDouble(),
        unit: (map[SalesTable.cUnit] as String?) ?? 'ربطة',
        unitPrice: (map[SalesTable.cUnitPrice] as num).toDouble(),
        totalAmount: (map[SalesTable.cTotalAmount] as num).toDouble(),
        paymentStatus: (map[SalesTable.cPaymentStatus] as String?) ?? 'نقد',
        paidAmount: (map[SalesTable.cPaidAmount] as num?)?.toDouble() ?? 0,
        remainingAmount: (map[SalesTable.cRemainingAmount] as num?)?.toDouble() ?? 0,
        profit: (map[SalesTable.cProfit] as num?)?.toDouble(),
        notes: map[SalesTable.cNotes] as String?,
      );

  @override
  Map<String, Object?> toMap() => {
        SalesTable.cId: id,
        SalesTable.cDate: date,
        SalesTable.cTime: time,
        SalesTable.cCustomerId: customerId,
        SalesTable.cQatTypeId: qatTypeId,
        SalesTable.cQuantity: quantity,
        SalesTable.cUnit: unit,
        SalesTable.cUnitPrice: unitPrice,
        SalesTable.cTotalAmount: totalAmount,
        SalesTable.cPaymentStatus: paymentStatus,
        SalesTable.cPaidAmount: paidAmount,
        SalesTable.cRemainingAmount: remainingAmount,
        SalesTable.cProfit: profit,
        SalesTable.cNotes: notes,
      };
}
