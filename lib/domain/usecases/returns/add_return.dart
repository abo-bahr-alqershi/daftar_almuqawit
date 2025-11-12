import '../../entities/return_item.dart';
import '../../repositories/returns_repository.dart';
import '../base/base_usecase.dart';

/// حالة استخدام إضافة مردود
class AddReturn implements UseCase<int, AddReturnParams> {
  final ReturnsRepository repository;

  AddReturn(this.repository);

  @override
  Future<int> call(AddReturnParams params) async {
    // التحقق من صحة البيانات
    _validateParams(params);

    // إنشاء كيان المردود
    final returnItem = ReturnItem(
      returnDate: DateTime.now().toIso8601String().split('T')[0],
      returnTime: _getCurrentTime(),
      returnType: params.returnType,
      returnNumber: _generateReturnNumber(),
      customerId: params.customerId,
      customerName: params.customerName,
      supplierId: params.supplierId,
      supplierName: params.supplierName,
      qatTypeId: params.qatTypeId,
      qatTypeName: params.qatTypeName,
      unit: params.unit,
      quantity: params.quantity,
      unitPrice: params.unitPrice,
      totalAmount: params.quantity * params.unitPrice,
      returnReason: params.returnReason,
      notes: params.notes,
      originalSaleId: params.originalSaleId,
      originalPurchaseId: params.originalPurchaseId,
      originalInvoiceNumber: params.originalInvoiceNumber,
      createdBy: params.createdBy,
    );

    return await repository.addReturn(returnItem);
  }

  void _validateParams(AddReturnParams params) {
    if (params.qatTypeId <= 0) {
      throw Exception('معرف نوع القات مطلوب');
    }
    if (params.quantity <= 0) {
      throw Exception('الكمية يجب أن تكون أكبر من صفر');
    }
    if (params.unitPrice < 0) {
      throw Exception('سعر الوحدة يجب أن يكون موجباً');
    }
    if (params.returnReason.trim().isEmpty) {
      throw Exception('سبب المردود مطلوب');
    }
    if (params.returnType == 'مردود_مبيعات' && params.customerId == null) {
      throw Exception('معرف العميل مطلوب لمردود المبيعات');
    }
    if (params.returnType == 'مردود_مشتريات' && params.supplierId == null) {
      throw Exception('معرف المورد مطلوب لمردود المشتريات');
    }
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  String _generateReturnNumber() {
    final now = DateTime.now();
    return 'RET-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(8)}';
  }
}

/// معاملات إضافة مردود
class AddReturnParams {
  final int qatTypeId;
  final String qatTypeName;
  final String unit;
  final double quantity;
  final double unitPrice;
  final String returnReason;
  final String returnType;
  final int? customerId;
  final String? customerName;
  final int? supplierId;
  final String? supplierName;
  final int? originalSaleId;
  final int? originalPurchaseId;
  final String? originalInvoiceNumber;
  final String? notes;
  final String? createdBy;

  const AddReturnParams({
    required this.qatTypeId,
    required this.qatTypeName,
    required this.unit,
    required this.quantity,
    required this.unitPrice,
    required this.returnReason,
    required this.returnType,
    this.customerId,
    this.customerName,
    this.supplierId,
    this.supplierName,
    this.originalSaleId,
    this.originalPurchaseId,
    this.originalInvoiceNumber,
    this.notes,
    this.createdBy,
  });
}
