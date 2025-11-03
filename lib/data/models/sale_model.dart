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

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'time': time,
        'customerId': customerId,
        'qatTypeId': qatTypeId,
        'quantity': quantity,
        'unit': unit,
        'unitPrice': unitPrice,
        'totalAmount': totalAmount,
        'paymentStatus': paymentStatus,
        'paidAmount': paidAmount,
        'remainingAmount': remainingAmount,
        'profit': profit,
        'notes': notes,
      };

  @override
  SaleModel copyWith({
    int? id,
    String? date,
    String? time,
    int? customerId,
    int? qatTypeId,
    double? quantity,
    String? unit,
    double? unitPrice,
    double? totalAmount,
    String? paymentStatus,
    double? paidAmount,
    double? remainingAmount,
    double? profit,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? firebaseId,
    String? syncStatus,
  }) =>
      SaleModel(
        id: id ?? this.id,
        date: date ?? this.date,
        time: time ?? this.time,
        customerId: customerId ?? this.customerId,
        qatTypeId: qatTypeId ?? this.qatTypeId,
        quantity: quantity ?? this.quantity,
        unit: unit ?? this.unit,
        unitPrice: unitPrice ?? this.unitPrice,
        totalAmount: totalAmount ?? this.totalAmount,
        paymentStatus: paymentStatus ?? this.paymentStatus,
        paidAmount: paidAmount ?? this.paidAmount,
        remainingAmount: remainingAmount ?? this.remainingAmount,
        profit: profit ?? this.profit,
        notes: notes ?? this.notes,
      );

  @override
  List<Object?> get props => [id, date, time, customerId, qatTypeId, quantity, unit, unitPrice, totalAmount, paymentStatus, paidAmount, remainingAmount, profit, notes];
}
