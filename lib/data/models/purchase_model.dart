// ignore_for_file: public_member_api_docs

import 'base/base_model.dart';
import '../database/tables/purchases_table.dart';
import '../../domain/entities/purchase.dart';

class PurchaseModel extends BaseModel {
  final int? id;
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
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final String? firebaseId;
  @override
  final String? syncStatus;

  const PurchaseModel({
    this.id,
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
    this.firebaseId,
    this.syncStatus,
  });

  factory PurchaseModel.fromMap(Map<String, Object?> map) {
    final createdAtStr = map[PurchasesTable.cCreatedAt] as String?;
    final updatedAtStr = map[PurchasesTable.cUpdatedAt] as String?;
    
    return PurchaseModel(
      id: map[PurchasesTable.cId] as int?,
      date: map[PurchasesTable.cDate] as String,
      time: map[PurchasesTable.cTime] as String,
      supplierId: map[PurchasesTable.cSupplierId] as int?,
      supplierName: map[PurchasesTable.cSupplierName] as String?,
      qatTypeId: map[PurchasesTable.cQatTypeId] as int?,
      qatTypeName: map[PurchasesTable.cQatTypeName] as String?,
      quantity: (map[PurchasesTable.cQuantity] as num).toDouble(),
      unit: (map[PurchasesTable.cUnit] as String?) ?? 'ربطة',
      unitPrice: (map[PurchasesTable.cUnitPrice] as num).toDouble(),
      totalAmount: (map[PurchasesTable.cTotalAmount] as num).toDouble(),
      paymentMethod: (map[PurchasesTable.cPaymentMethod] as String?) ?? 'نقد',
      paymentStatus: (map[PurchasesTable.cPaymentStatus] as String?) ?? 'مدفوع',
      paidAmount: (map[PurchasesTable.cPaidAmount] as num?)?.toDouble() ?? 0,
      remainingAmount: (map[PurchasesTable.cRemainingAmount] as num?)?.toDouble() ?? 0,
      dueDate: map[PurchasesTable.cDueDate] as String?,
      invoiceNumber: map[PurchasesTable.cInvoiceNumber] as String?,
      status: (map[PurchasesTable.cStatus] as String?) ?? 'نشط',
      notes: map[PurchasesTable.cNotes] as String?,
      createdAt: createdAtStr != null ? DateTime.tryParse(createdAtStr) : null,
      updatedAt: updatedAtStr != null ? DateTime.tryParse(updatedAtStr) : null,
      firebaseId: map[PurchasesTable.cFirebaseId] as String?,
      syncStatus: map[PurchasesTable.cSyncStatus] as String?,
    );
  }

  @override
  Map<String, Object?> toMap() => {
        PurchasesTable.cId: id,
        PurchasesTable.cDate: date,
        PurchasesTable.cTime: time,
        PurchasesTable.cSupplierId: supplierId,
        PurchasesTable.cSupplierName: supplierName,
        PurchasesTable.cQatTypeId: qatTypeId,
        PurchasesTable.cQatTypeName: qatTypeName,
        PurchasesTable.cQuantity: quantity,
        PurchasesTable.cUnit: unit,
        PurchasesTable.cUnitPrice: unitPrice,
        PurchasesTable.cTotalAmount: totalAmount,
        PurchasesTable.cPaymentMethod: paymentMethod,
        PurchasesTable.cPaymentStatus: paymentStatus,
        PurchasesTable.cPaidAmount: paidAmount,
        PurchasesTable.cRemainingAmount: remainingAmount,
        PurchasesTable.cDueDate: dueDate,
        PurchasesTable.cInvoiceNumber: invoiceNumber,
        PurchasesTable.cStatus: status,
        PurchasesTable.cNotes: notes,
        PurchasesTable.cCreatedAt: createdAt?.toIso8601String(),
        PurchasesTable.cUpdatedAt: updatedAt?.toIso8601String(),
        PurchasesTable.cSyncStatus: syncStatus,
        PurchasesTable.cFirebaseId: firebaseId,
      };

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'time': time,
        'supplierId': supplierId,
        'supplierName': supplierName,
        'qatTypeId': qatTypeId,
        'qatTypeName': qatTypeName,
        'quantity': quantity,
        'unit': unit,
        'unitPrice': unitPrice,
        'totalAmount': totalAmount,
        'paymentMethod': paymentMethod,
        'paymentStatus': paymentStatus,
        'paidAmount': paidAmount,
        'remainingAmount': remainingAmount,
        'dueDate': dueDate,
        'invoiceNumber': invoiceNumber,
        'status': status,
        'notes': notes,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'firebaseId': firebaseId,
        'syncStatus': syncStatus,
      };

  @override
  PurchaseModel copyWith({
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
    DateTime? createdAt,
    DateTime? updatedAt,
    String? firebaseId,
    String? syncStatus,
  }) =>
      PurchaseModel(
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
        firebaseId: firebaseId ?? this.firebaseId,
        syncStatus: syncStatus ?? this.syncStatus,
      );

  /// تحويل إلى كيان
  Purchase toEntity() => Purchase(
        id: id,
        date: date,
        time: time,
        supplierId: supplierId,
        supplierName: supplierName,
        qatTypeId: qatTypeId,
        qatTypeName: qatTypeName,
        quantity: quantity,
        unit: unit,
        unitPrice: unitPrice,
        totalAmount: totalAmount,
        paymentMethod: paymentMethod,
        paymentStatus: paymentStatus,
        paidAmount: paidAmount,
        remainingAmount: remainingAmount,
        dueDate: dueDate,
        invoiceNumber: invoiceNumber,
        status: status,
        notes: notes,
        createdAt: createdAt?.toIso8601String(),
        updatedAt: updatedAt?.toIso8601String(),
      );

  /// إنشاء من كيان
  factory PurchaseModel.fromEntity(Purchase entity) => PurchaseModel(
        id: entity.id,
        date: entity.date,
        time: entity.time,
        supplierId: entity.supplierId,
        supplierName: entity.supplierName,
        qatTypeId: entity.qatTypeId,
        qatTypeName: entity.qatTypeName,
        quantity: entity.quantity,
        unit: entity.unit,
        unitPrice: entity.unitPrice,
        totalAmount: entity.totalAmount,
        paymentMethod: entity.paymentMethod,
        paymentStatus: entity.paymentStatus,
        paidAmount: entity.paidAmount,
        remainingAmount: entity.remainingAmount,
        dueDate: entity.dueDate,
        invoiceNumber: entity.invoiceNumber,
        status: entity.status,
        notes: entity.notes,
        createdAt: entity.createdAt != null ? DateTime.tryParse(entity.createdAt!) : null,
        updatedAt: entity.updatedAt != null ? DateTime.tryParse(entity.updatedAt!) : null,
      );

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
        firebaseId,
        syncStatus,
      ];
}
