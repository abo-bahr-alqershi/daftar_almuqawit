// ignore_for_file: public_member_api_docs

import '../../entities/debt_payment.dart';
import '../../repositories/debt_payment_repository.dart';
import '../base/base_usecase.dart';

/// حالة استخدام: تحديث دفعة دين
/// تستخدم لتعديل بيانات دفعة موجودة (مثل المبلغ أو طريقة الدفع أو الملاحظات)
class UpdateDebtPayment implements UseCase<int, DebtPayment> {
  /// مستودع دفعات الديون
  final DebtPaymentRepository repository;

  /// المُنشئ
  UpdateDebtPayment(this.repository);

  /// تنفيذ تحديث دفعة الدين
  /// [params] - كيان دفعة الدين المحدث
  /// يعيد عدد الصفوف المتأثرة (1 في حالة النجاح)
  @override
  Future<int> call(DebtPayment params) async {
    return await repository.update(params);
  }
}
