import 'base/base_entity.dart';

/// كيان المردود
/// 
/// يمثل عنصر مردود من عميل أو إلى مورد
class ReturnItem extends BaseEntity {
  final String returnDate;
  final String returnTime;
  final String returnType; // مردود_مبيعات، مردود_مشتريات
  final String returnNumber;
  final int? customerId;
  final String? customerName;
  final int? supplierId;
  final String? supplierName;
  final int qatTypeId;
  final String qatTypeName;
  final String unit;
  final double quantity;
  final double unitPrice;
  final double totalAmount;
  final String returnReason;
  final String? notes;
  final String status; // معلق، مؤكد، ملغي
  final int? originalSaleId;
  final int? originalPurchaseId;
  final String? originalInvoiceNumber;
  final String? createdBy;
  final String? createdAt;
  final String? updatedAt;
  final String? syncStatus;
  final String? firebaseId;

  const ReturnItem({
    super.id,
    required this.returnDate,
    required this.returnTime,
    required this.returnType,
    required this.returnNumber,
    this.customerId,
    this.customerName,
    this.supplierId,
    this.supplierName,
    required this.qatTypeId,
    required this.qatTypeName,
    required this.unit,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    required this.returnReason,
    this.notes,
    this.status = 'معلق',
    this.originalSaleId,
    this.originalPurchaseId,
    this.originalInvoiceNumber,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.syncStatus = 'pending',
    this.firebaseId,
  });

  /// هل المردود من مبيعات؟
  bool get isSalesReturn => returnType == 'مردود_مبيعات';

  /// هل المردود من مشتريات؟
  bool get isPurchaseReturn => returnType == 'مردود_مشتريات';

  /// هل المردود مؤكد؟
  bool get isConfirmed => status == 'مؤكد';

  /// هل المردود معلق؟
  bool get isPending => status == 'معلق';

  /// هل المردود ملغي؟
  bool get isCancelled => status == 'ملغي';

  /// اسم الشخص المرتبط بالمردود
  String get relatedPersonName {
    if (isSalesReturn) return customerName ?? 'عميل غير محدد';
    if (isPurchaseReturn) return supplierName ?? 'مورد غير محدد';
    return 'غير محدد';
  }

  /// معرف الشخص المرتبط
  int? get relatedPersonId {
    if (isSalesReturn) return customerId;
    if (isPurchaseReturn) return supplierId;
    return null;
  }

  /// نوع الإرجاع للعرض
  String get displayReturnType {
    switch (returnType) {
      case 'مردود_مبيعات':
        return 'مردود مبيعات';
      case 'مردود_مشتريات':
        return 'مردود مشتريات';
      default:
        return returnType;
    }
  }

  /// لون حالة المردود
  String get statusColor {
    switch (status) {
      case 'مؤكد':
        return 'green';
      case 'معلق':
        return 'orange';
      case 'ملغي':
        return 'red';
      default:
        return 'grey';
    }
  }

  /// أيقونة نوع المردود
  String get typeIcon {
    if (isSalesReturn) return 'keyboard_return';
    if (isPurchaseReturn) return 'undo';
    return 'cached';
  }

  ReturnItem copyWith({
    int? id,
    String? returnDate,
    String? returnTime,
    String? returnType,
    String? returnNumber,
    int? customerId,
    String? customerName,
    int? supplierId,
    String? supplierName,
    int? qatTypeId,
    String? qatTypeName,
    String? unit,
    double? quantity,
    double? unitPrice,
    double? totalAmount,
    String? returnReason,
    String? notes,
    String? status,
    int? originalSaleId,
    int? originalPurchaseId,
    String? originalInvoiceNumber,
    String? createdBy,
    String? createdAt,
    String? updatedAt,
    String? syncStatus,
    String? firebaseId,
  }) {
    return ReturnItem(
      id: id ?? this.id,
      returnDate: returnDate ?? this.returnDate,
      returnTime: returnTime ?? this.returnTime,
      returnType: returnType ?? this.returnType,
      returnNumber: returnNumber ?? this.returnNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      qatTypeId: qatTypeId ?? this.qatTypeId,
      qatTypeName: qatTypeName ?? this.qatTypeName,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalAmount: totalAmount ?? this.totalAmount,
      returnReason: returnReason ?? this.returnReason,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      originalSaleId: originalSaleId ?? this.originalSaleId,
      originalPurchaseId: originalPurchaseId ?? this.originalPurchaseId,
      originalInvoiceNumber: originalInvoiceNumber ?? this.originalInvoiceNumber,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      firebaseId: firebaseId ?? this.firebaseId,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'returnDate': returnDate,
    'returnTime': returnTime,
    'returnType': returnType,
    'returnNumber': returnNumber,
    'customerId': customerId,
    'customerName': customerName,
    'supplierId': supplierId,
    'supplierName': supplierName,
    'qatTypeId': qatTypeId,
    'qatTypeName': qatTypeName,
    'unit': unit,
    'quantity': quantity,
    'unitPrice': unitPrice,
    'totalAmount': totalAmount,
    'returnReason': returnReason,
    'notes': notes,
    'status': status,
    'originalSaleId': originalSaleId,
    'originalPurchaseId': originalPurchaseId,
    'originalInvoiceNumber': originalInvoiceNumber,
    'createdBy': createdBy,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'syncStatus': syncStatus,
    'firebaseId': firebaseId,
  };
}

/// أسباب المردود الشائعة
class ReturnReasons {
  static const List<String> salesReturns = [
    'عيب في المنتج',
    'منتج غير مطابق للمواصفات',
    'تلف أثناء النقل',
    'العميل غيّر رأيه',
    'منتج منتهي الصلاحية',
    'كمية زائدة',
    'خطأ في الطلب',
    'أخرى',
  ];

  static const List<String> purchaseReturns = [
    'عيب في المنتج',
    'منتج غير مطابق للمواصفات',
    'تلف أثناء النقل',
    'منتج منتهي الصلاحية',
    'كمية زائدة عن الطلب',
    'خطأ في الطلب',
    'جودة رديئة',
    'أخرى',
  ];

  static List<String> getReasonsByType(String returnType) {
    switch (returnType) {
      case 'مردود_مبيعات':
        return salesReturns;
      case 'مردود_مشتريات':
        return purchaseReturns;
      default:
        return [...salesReturns, ...purchaseReturns];
    }
  }
}
