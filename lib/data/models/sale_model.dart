// ignore_for_file: public_member_api_docs

import 'base/base_model.dart';
import '../database/tables/sales_table.dart';
import '../../domain/entities/sale.dart';

class SaleModel extends BaseModel {
  final int? id;
  final String date;
  final String time;
  final int? customerId;
  final String? customerName;
  final int? qatTypeId;
  final String? qatTypeName;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double costPrice;
  final double totalAmount;
  final double profit;
  final double profitMargin;
  final String paymentMethod;
  final String paymentStatus;
  final double paidAmount;
  final double remainingAmount;
  final String? dueDate;
  final String? invoiceNumber;
  final String saleType;
  final double discount;
  final String discountType;
  final String status;
  final int isQuickSale;
  final String? soldBy;
  final String? notes;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final String? firebaseId;
  @override
  final String? syncStatus;

  const SaleModel({
    this.id,
    required this.date,
    required this.time,
    this.customerId,
    this.customerName,
    this.qatTypeId,
    this.qatTypeName,
    required this.quantity,
    this.unit = 'ربطة',
    required this.unitPrice,
    this.costPrice = 0,
    required this.totalAmount,
    this.profit = 0,
    this.profitMargin = 0,
    this.paymentMethod = 'نقد',
    this.paymentStatus = 'مدفوع',
    this.paidAmount = 0,
    this.remainingAmount = 0,
    this.dueDate,
    this.invoiceNumber,
    this.saleType = 'عادي',
    this.discount = 0,
    this.discountType = 'قيمة',
    this.status = 'نشط',
    this.isQuickSale = 0,
    this.soldBy,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.firebaseId,
    this.syncStatus,
  });

  factory SaleModel.fromMap(Map<String, Object?> map) {
    final createdAtStr = map[SalesTable.cCreatedAt] as String?;
    final updatedAtStr = map[SalesTable.cUpdatedAt] as String?;
    
    return SaleModel(
      id: map[SalesTable.cId] as int?,
      date: map[SalesTable.cDate] as String,
      time: map[SalesTable.cTime] as String,
      customerId: map[SalesTable.cCustomerId] as int?,
      customerName: map[SalesTable.cCustomerName] as String?,
      qatTypeId: map[SalesTable.cQatTypeId] as int?,
      qatTypeName: map[SalesTable.cQatTypeName] as String?,
      quantity: (map[SalesTable.cQuantity] as num).toDouble(),
      unit: (map[SalesTable.cUnit] as String?) ?? 'ربطة',
      unitPrice: (map[SalesTable.cUnitPrice] as num).toDouble(),
      costPrice: (map[SalesTable.cCostPrice] as num?)?.toDouble() ?? 0,
      totalAmount: (map[SalesTable.cTotalAmount] as num).toDouble(),
      profit: (map[SalesTable.cProfit] as num?)?.toDouble() ?? 0,
      profitMargin: (map[SalesTable.cProfitMargin] as num?)?.toDouble() ?? 0,
      paymentMethod: (map[SalesTable.cPaymentMethod] as String?) ?? 'نقد',
      paymentStatus: (map[SalesTable.cPaymentStatus] as String?) ?? 'مدفوع',
      paidAmount: (map[SalesTable.cPaidAmount] as num?)?.toDouble() ?? 0,
      remainingAmount: (map[SalesTable.cRemainingAmount] as num?)?.toDouble() ?? 0,
      dueDate: map[SalesTable.cDueDate] as String?,
      invoiceNumber: map[SalesTable.cInvoiceNumber] as String?,
      saleType: (map[SalesTable.cSaleType] as String?) ?? 'عادي',
      discount: (map[SalesTable.cDiscount] as num?)?.toDouble() ?? 0,
      discountType: (map[SalesTable.cDiscountType] as String?) ?? 'قيمة',
      status: (map[SalesTable.cStatus] as String?) ?? 'نشط',
      isQuickSale: (map[SalesTable.cIsQuickSale] as int?) ?? 0,
      soldBy: map[SalesTable.cSoldBy] as String?,
      notes: map[SalesTable.cNotes] as String?,
      createdAt: createdAtStr != null ? DateTime.tryParse(createdAtStr) : null,
      updatedAt: updatedAtStr != null ? DateTime.tryParse(updatedAtStr) : null,
      firebaseId: map[SalesTable.cFirebaseId] as String?,
      syncStatus: map[SalesTable.cSyncStatus] as String?,
    );
  }

  @override
  Map<String, Object?> toMap() => {
        SalesTable.cId: id,
        SalesTable.cDate: date,
        SalesTable.cTime: time,
        SalesTable.cCustomerId: customerId,
        SalesTable.cCustomerName: customerName,
        SalesTable.cQatTypeId: qatTypeId,
        SalesTable.cQatTypeName: qatTypeName,
        SalesTable.cQuantity: quantity,
        SalesTable.cUnit: unit,
        SalesTable.cUnitPrice: unitPrice,
        SalesTable.cCostPrice: costPrice,
        SalesTable.cTotalAmount: totalAmount,
        SalesTable.cProfit: profit,
        SalesTable.cProfitMargin: profitMargin,
        SalesTable.cPaymentMethod: paymentMethod,
        SalesTable.cPaymentStatus: paymentStatus,
        SalesTable.cPaidAmount: paidAmount,
        SalesTable.cRemainingAmount: remainingAmount,
        SalesTable.cDueDate: dueDate,
        SalesTable.cInvoiceNumber: invoiceNumber,
        SalesTable.cSaleType: saleType,
        SalesTable.cDiscount: discount,
        SalesTable.cDiscountType: discountType,
        SalesTable.cStatus: status,
        SalesTable.cIsQuickSale: isQuickSale,
        SalesTable.cSoldBy: soldBy,
        SalesTable.cNotes: notes,
        SalesTable.cCreatedAt: createdAt?.toIso8601String(),
        SalesTable.cUpdatedAt: updatedAt?.toIso8601String(),
        SalesTable.cSyncStatus: syncStatus,
        SalesTable.cFirebaseId: firebaseId,
      };

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'time': time,
        'customerId': customerId,
        'customerName': customerName,
        'qatTypeId': qatTypeId,
        'qatTypeName': qatTypeName,
        'quantity': quantity,
        'unit': unit,
        'unitPrice': unitPrice,
        'costPrice': costPrice,
        'totalAmount': totalAmount,
        'profit': profit,
        'profitMargin': profitMargin,
        'paymentMethod': paymentMethod,
        'paymentStatus': paymentStatus,
        'paidAmount': paidAmount,
        'remainingAmount': remainingAmount,
        'dueDate': dueDate,
        'invoiceNumber': invoiceNumber,
        'saleType': saleType,
        'discount': discount,
        'discountType': discountType,
        'status': status,
        'isQuickSale': isQuickSale,
        'soldBy': soldBy,
        'notes': notes,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'firebaseId': firebaseId,
        'syncStatus': syncStatus,
      };

  @override
  SaleModel copyWith({
    int? id,
    String? date,
    String? time,
    int? customerId,
    String? customerName,
    int? qatTypeId,
    String? qatTypeName,
    double? quantity,
    String? unit,
    double? unitPrice,
    double? costPrice,
    double? totalAmount,
    double? profit,
    double? profitMargin,
    String? paymentMethod,
    String? paymentStatus,
    double? paidAmount,
    double? remainingAmount,
    String? dueDate,
    String? invoiceNumber,
    String? saleType,
    double? discount,
    String? discountType,
    String? status,
    int? isQuickSale,
    String? soldBy,
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
        customerName: customerName ?? this.customerName,
        qatTypeId: qatTypeId ?? this.qatTypeId,
        qatTypeName: qatTypeName ?? this.qatTypeName,
        quantity: quantity ?? this.quantity,
        unit: unit ?? this.unit,
        unitPrice: unitPrice ?? this.unitPrice,
        costPrice: costPrice ?? this.costPrice,
        totalAmount: totalAmount ?? this.totalAmount,
        profit: profit ?? this.profit,
        profitMargin: profitMargin ?? this.profitMargin,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        paymentStatus: paymentStatus ?? this.paymentStatus,
        paidAmount: paidAmount ?? this.paidAmount,
        remainingAmount: remainingAmount ?? this.remainingAmount,
        dueDate: dueDate ?? this.dueDate,
        invoiceNumber: invoiceNumber ?? this.invoiceNumber,
        saleType: saleType ?? this.saleType,
        discount: discount ?? this.discount,
        discountType: discountType ?? this.discountType,
        status: status ?? this.status,
        isQuickSale: isQuickSale ?? this.isQuickSale,
        soldBy: soldBy ?? this.soldBy,
        notes: notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        firebaseId: firebaseId ?? this.firebaseId,
        syncStatus: syncStatus ?? this.syncStatus,
      );

  /// تحويل إلى كيان
  Sale toEntity() => Sale(
        id: id,
        date: date,
        time: time,
        customerId: customerId,
        customerName: customerName,
        qatTypeId: qatTypeId,
        qatTypeName: qatTypeName,
        quantity: quantity,
        unit: unit,
        unitPrice: unitPrice,
        costPrice: costPrice,
        totalAmount: totalAmount,
        profit: profit,
        profitMargin: profitMargin,
        paymentMethod: paymentMethod,
        paymentStatus: paymentStatus,
        paidAmount: paidAmount,
        remainingAmount: remainingAmount,
        dueDate: dueDate,
        invoiceNumber: invoiceNumber,
        saleType: saleType,
        discount: discount,
        discountType: discountType,
        status: status,
        isQuickSale: isQuickSale == 1,
        soldBy: soldBy,
        notes: notes,
        createdAt: createdAt?.toIso8601String(),
        updatedAt: updatedAt?.toIso8601String(),
      );

  /// إنشاء من كيان
  factory SaleModel.fromEntity(Sale entity) => SaleModel(
        id: entity.id,
        date: entity.date,
        time: entity.time,
        customerId: entity.customerId,
        customerName: entity.customerName,
        qatTypeId: entity.qatTypeId,
        qatTypeName: entity.qatTypeName,
        quantity: entity.quantity,
        unit: entity.unit,
        unitPrice: entity.unitPrice,
        costPrice: entity.costPrice,
        totalAmount: entity.totalAmount,
        profit: entity.profit,
        profitMargin: entity.profitMargin,
        paymentMethod: entity.paymentMethod,
        paymentStatus: entity.paymentStatus,
        paidAmount: entity.paidAmount,
        remainingAmount: entity.remainingAmount,
        dueDate: entity.dueDate,
        invoiceNumber: entity.invoiceNumber,
        saleType: entity.saleType,
        discount: entity.discount,
        discountType: entity.discountType,
        status: entity.status,
        isQuickSale: entity.isQuickSale ? 1 : 0,
        soldBy: entity.soldBy,
        notes: entity.notes,
        createdAt: entity.createdAt != null ? DateTime.tryParse(entity.createdAt!) : null,
        updatedAt: entity.updatedAt != null ? DateTime.tryParse(entity.updatedAt!) : null,
      );

  @override
  List<Object?> get props => [
        id,
        date,
        time,
        customerId,
        customerName,
        qatTypeId,
        qatTypeName,
        quantity,
        unit,
        unitPrice,
        costPrice,
        totalAmount,
        profit,
        profitMargin,
        paymentMethod,
        paymentStatus,
        paidAmount,
        remainingAmount,
        dueDate,
        invoiceNumber,
        saleType,
        discount,
        discountType,
        status,
        isQuickSale,
        soldBy,
        notes,
        createdAt,
        updatedAt,
        firebaseId,
        syncStatus,
      ];
}
