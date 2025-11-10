// ignore_for_file: public_member_api_docs

import '../../repositories/debt_payment_repository.dart';
import '../base/base_usecase.dart';

/// حالة استخدام: حذف دفعة دين
/// تستخدم لحذف دفعة من قاعدة البيانات
class DeleteDebtPayment implements UseCase<int, int> {
  /// مستودع دفعات الديون
  final DebtPaymentRepository repository;

  /// المُنشئ
  DeleteDebtPayment(this.repository);

  /// تنفيذ حذف دفعة الدين
  /// [params] - معرف دفعة الدين المراد حذفها
  /// يعيد عدد الصفوف المتأثرة (1 في حالة النجاح)
  @override
  Future<int> call(int params) async {
    return await repository.delete(params);
  }
}
