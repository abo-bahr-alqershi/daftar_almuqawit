// ignore_for_file: public_member_api_docs

import 'base/base_entity.dart';

/// كيان عملية شراء
class Purchase extends BaseEntity {
  final String date;
  final String time;
  final int? supplierId;
  final String? supplierName;
  final int? qatTypeId;
  final String? qatTypeName;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double totalAmount;
  final String paymentMethod;
  final String paymentStatus;
  final double paidAmount;
  final double remainingAmount;
  final String? dueDate;
  final String? invoiceNumber;
  final String status;
  final String? notes;
  final String? createdAt;
  final String? updatedAt;
  
  // خصائص إضافية للتوافق
  /// سعر الوحدة (نفس unitPrice)
  double get pricePerUnit => unitPrice;
  
  /// هل تم الدفع بالكامل
  bool get isPaid => paymentStatus == 'مدفوع' || remainingAmount == 0;

  const Purchase({
    super.id,
    required this.date,
    required this.time,
    this.supplierId,
    this.supplierName,
    this.qatTypeId,
    this.qatTypeName,
    required this.quantity,
    this.unit = 'ربطة',
    required this.unitPrice,
    required this.totalAmount,
    this.paymentMethod = 'نقد',
    this.paymentStatus = 'مدفوع',
    this.paidAmount = 0,
    this.remainingAmount = 0,
    this.dueDate,
    this.invoiceNumber,
    this.status = 'نشط',
    this.notes,
    this.createdAt,
    this.updatedAt,
  });
  
  /// نسخ الكيان مع تحديث بعض الخصائص
  Purchase copyWith({
    int? id,
    String? date,
    String? time,
    int? supplierId,
    String? supplierName,
    int? qatTypeId,
    String? qatTypeName,
    double? quantity,
    String? unit,
    double? unitPrice,
    double? totalAmount,
    String? paymentMethod,
    String? paymentStatus,
    double? paidAmount,
    double? remainingAmount,
    String? dueDate,
    String? invoiceNumber,
    String? status,
    String? notes,
    String? createdAt,
    String? updatedAt,
  }) {
    return Purchase(
      id: id ?? this.id,
      date: date ?? this.date,
      time: time ?? this.time,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      qatTypeId: qatTypeId ?? this.qatTypeId,
      qatTypeName: qatTypeName ?? this.qatTypeName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitPrice: unitPrice ?? this.unitPrice,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paidAmount: paidAmount ?? this.paidAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      dueDate: dueDate ?? this.dueDate,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      status: status ?? this.status,
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
        supplierId,
        supplierName,
        qatTypeId,
        qatTypeName,
        quantity,
        unit,
        unitPrice,
        totalAmount,
        paymentMethod,
        paymentStatus,
        paidAmount,
        remainingAmount,
        dueDate,
        invoiceNumber,
        status,
        notes,
        createdAt,
        updatedAt,
      ];
  
  /// تحويل الشراء إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'time': time,
      'supplier_id': supplierId,
      'supplier_name': supplierName,
      'qat_type_id': qatTypeId,
      'qat_type_name': qatTypeName,
      'quantity': quantity,
      'unit': unit,
      'unit_price': unitPrice,
      'total_amount': totalAmount,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'paid_amount': paidAmount,
      'remaining_amount': remainingAmount,
      'due_date': dueDate,
      'invoice_number': invoiceNumber,
      'status': status,
      'notes': notes,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
