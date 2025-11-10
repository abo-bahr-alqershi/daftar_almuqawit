// ignore_for_file: public_member_api_docs

import 'base/base_entity.dart';

/// كيان عملية بيع
class Sale extends BaseEntity {
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
  final bool isQuickSale;
  final String? soldBy;
  final String? notes;
  final String? createdAt;
  final String? updatedAt;

  const Sale({
    super.id,
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
    this.isQuickSale = false,
    this.soldBy,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });
  
  /// نسخ الكيان مع تحديث بعض الخصائص
  Sale copyWith({
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
    bool? isQuickSale,
    String? soldBy,
    String? notes,
    String? createdAt,
    String? updatedAt,
  }) {
    return Sale(
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
    );
  }

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
      ];
  
  /// تحويل البيع إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'time': time,
      'customer_id': customerId,
      'customer_name': customerName,
      'qat_type_id': qatTypeId,
      'qat_type_name': qatTypeName,
      'quantity': quantity,
      'unit': unit,
      'unit_price': unitPrice,
      'cost_price': costPrice,
      'total_amount': totalAmount,
      'profit': profit,
      'profit_margin': profitMargin,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'paid_amount': paidAmount,
      'remaining_amount': remainingAmount,
      'due_date': dueDate,
      'invoice_number': invoiceNumber,
      'sale_type': saleType,
      'discount': discount,
      'discount_type': discountType,
      'status': status,
      'is_quick_sale': isQuickSale,
      'sold_by': soldBy,
      'notes': notes,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
