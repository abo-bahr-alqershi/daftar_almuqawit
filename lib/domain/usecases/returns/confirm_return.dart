import '../../repositories/returns_repository.dart';
import '../base/base_usecase.dart';

/// حالة استخدام تأكيد مردود
class ConfirmReturn implements UseCase<bool, ConfirmReturnParams> {
  final ReturnsRepository repository;

  ConfirmReturn(this.repository);

  @override
  Future<bool> call(ConfirmReturnParams params) async {
    try {
      // التحقق من صحة المعاملات
      if (params.returnId <= 0) {
        throw Exception('معرف المردود غير صحيح');
      }

      // تأكيد المردود
      final success = await repository.confirmReturn(params.returnId);
      
      if (!success) {
        throw Exception('فشل في تأكيد المردود');
      }

      return success;
    } catch (e) {
      throw Exception('خطأ في تأكيد المردود: $e');
    }
  }
}

/// معاملات تأكيد مردود
class ConfirmReturnParams {
  final int returnId;

  const ConfirmReturnParams({
    required this.returnId,
  });
}
