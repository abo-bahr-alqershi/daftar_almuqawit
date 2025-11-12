import '../base/base_usecase.dart';
import '../../repositories/inventory_repository.dart';

/// حالة استخدام تعديل كمية المخزون
class AdjustInventoryQuantity implements UseCase<bool, AdjustInventoryQuantityParams> {
  final InventoryRepository repository;

  const AdjustInventoryQuantity(this.repository);

  @override
  Future<bool> call(AdjustInventoryQuantityParams params) async {
    try {
      // التحقق من صحة البيانات
      _validateParams(params);

      // تنفيذ التعديل
      return await repository.adjustInventoryQuantity(
        params.qatTypeId,
        params.unit,
        params.newQuantity,
        params.reason,
        warehouseId: params.warehouseId,
      );
    } catch (e) {
      throw Exception('فشل في تعديل كمية المخزون: $e');
    }
  }

  void _validateParams(AdjustInventoryQuantityParams params) {
    if (params.qatTypeId <= 0) {
      throw Exception('معرف نوع القات غير صحيح');
    }

    if (params.unit.isEmpty) {
      throw Exception('الوحدة مطلوبة');
    }

    if (params.newQuantity < 0) {
      throw Exception('الكمية الجديدة يجب أن تكون موجبة أو صفر');
    }

    if (params.reason.trim().isEmpty) {
      throw Exception('سبب التعديل مطلوب');
    }

    if (params.warehouseId <= 0) {
      throw Exception('معرف المخزن غير صحيح');
    }
  }
}

/// معاملات تعديل كمية المخزون
class AdjustInventoryQuantityParams {
  final int qatTypeId;
  final String unit;
  final double newQuantity;
  final String reason;
  final int warehouseId;

  const AdjustInventoryQuantityParams({
    required this.qatTypeId,
    required this.unit,
    required this.newQuantity,
    required this.reason,
    this.warehouseId = 1,
  });

  /// أنواع أسباب التعديل المحددة مسبقاً
  static const List<String> commonReasons = [
    'جرد دوري',
    'تالف',
    'فاقد',
    'خطأ في الإدخال',
    'تسوية',
    'عينة',
    'أخرى',
  ];
}
