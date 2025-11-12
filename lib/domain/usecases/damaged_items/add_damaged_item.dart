import '../../entities/damaged_item.dart';
import '../../repositories/damaged_items_repository.dart';
import '../base/base_usecase.dart';

/// حالة استخدام إضافة بضاعة تالفة
class AddDamagedItem implements UseCase<int, AddDamagedItemParams> {
  final DamagedItemsRepository repository;

  AddDamagedItem(this.repository);

  @override
  Future<int> call(AddDamagedItemParams params) async {
    // التحقق من صحة البيانات
    _validateParams(params);

    // إنشاء كيان البضاعة التالفة
    final damagedItem = DamagedItem(
      damageDate: DateTime.now().toIso8601String().split('T')[0],
      damageTime: _getCurrentTime(),
      damageNumber: _generateDamageNumber(),
      qatTypeId: params.qatTypeId,
      qatTypeName: params.qatTypeName,
      unit: params.unit,
      quantity: params.quantity,
      unitCost: params.unitCost,
      totalCost: params.quantity * params.unitCost,
      damageReason: params.damageReason,
      damageType: params.damageType,
      severityLevel: params.severityLevel,
      notes: params.notes,
      isInsuranceCovered: params.isInsuranceCovered,
      insuranceAmount: params.insuranceAmount,
      responsiblePerson: params.responsiblePerson,
      warehouseId: params.warehouseId,
      warehouseName: params.warehouseName,
      batchNumber: params.batchNumber,
      expiryDate: params.expiryDate,
      discoveredBy: params.discoveredBy,
      createdBy: params.createdBy,
    );

    return await repository.addDamagedItem(damagedItem);
  }

  void _validateParams(AddDamagedItemParams params) {
    if (params.qatTypeId <= 0) {
      throw Exception('معرف نوع القات مطلوب');
    }
    if (params.quantity <= 0) {
      throw Exception('الكمية يجب أن تكون أكبر من صفر');
    }
    if (params.unitCost < 0) {
      throw Exception('تكلفة الوحدة يجب أن تكون موجبة');
    }
    if (params.damageReason.trim().isEmpty) {
      throw Exception('سبب التلف مطلوب');
    }
    if (!['تلف_طبيعي', 'تلف_بشري', 'تلف_خارجي', 'انتهاء_صلاحية'].contains(params.damageType)) {
      throw Exception('نوع التلف غير صحيح');
    }
    if (!['طفيف', 'متوسط', 'كبير', 'كارثي'].contains(params.severityLevel)) {
      throw Exception('مستوى الخطورة غير صحيح');
    }
    if (params.isInsuranceCovered && (params.insuranceAmount == null || params.insuranceAmount! <= 0)) {
      throw Exception('مبلغ التأمين مطلوب إذا كان مشمول بالتأمين');
    }
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  String _generateDamageNumber() {
    final now = DateTime.now();
    return 'DMG-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(8)}';
  }
}

/// معاملات إضافة بضاعة تالفة
class AddDamagedItemParams {
  final int qatTypeId;
  final String qatTypeName;
  final String unit;
  final double quantity;
  final double unitCost;
  final String damageReason;
  final String damageType;
  final String severityLevel;
  final String? notes;
  final bool isInsuranceCovered;
  final double? insuranceAmount;
  final String? responsiblePerson;
  final int warehouseId;
  final String warehouseName;
  final String? batchNumber;
  final String? expiryDate;
  final String? discoveredBy;
  final String? createdBy;

  const AddDamagedItemParams({
    required this.qatTypeId,
    required this.qatTypeName,
    required this.unit,
    required this.quantity,
    required this.unitCost,
    required this.damageReason,
    required this.damageType,
    this.severityLevel = 'متوسط',
    this.notes,
    this.isInsuranceCovered = false,
    this.insuranceAmount,
    this.responsiblePerson,
    this.warehouseId = 1,
    this.warehouseName = 'المخزن الرئيسي',
    this.batchNumber,
    this.expiryDate,
    this.discoveredBy,
    this.createdBy,
  });
}
