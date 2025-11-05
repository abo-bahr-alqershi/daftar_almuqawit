/// حالة استخدام سداد دين
/// تسجل المدفوعات وتحدث رصيد الدين وتنشئ إيصال سداد

import '../../entities/debt.dart';
import '../../entities/debt_payment.dart';
import '../../repositories/debt_repository.dart';
import '../../repositories/debt_payment_repository.dart';
import '../base/base_usecase.dart';

/// حالة استخدام سداد دين
class PayDebt implements UseCase<int, PayDebtParams> {
  final DebtRepository debtRepo;
  final DebtPaymentRepository paymentRepo;
  
  PayDebt(this.debtRepo, this.paymentRepo);
  
  @override
  Future<int> call(PayDebtParams params) async {
    // التحقق من صحة المبلغ
    if (params.amount <= 0) {
      throw ArgumentError('مبلغ الدفعة يجب أن يكون أكبر من صفر');
    }
    
    // جلب الدين
    final debt = await debtRepo.getById(params.debtId);
    if (debt == null) {
      throw StateError('الدين غير موجود');
    }
    
    // التحقق من أن المبلغ لا يتجاوز المتبقي
    if (params.amount > debt.remainingAmount) {
      throw ArgumentError('مبلغ الدفعة أكبر من المبلغ المتبقي');
    }
    
    // إنشاء سجل الدفعة
    final now = DateTime.now();
    final payment = DebtPayment(
      debtId: params.debtId,
      amount: params.amount,
      paymentDate: params.paymentDate ?? now.toIso8601String().split('T')[0],
      paymentTime: params.paymentTime ?? '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      paymentMethod: params.paymentMethod,
      notes: params.notes,
    );
    
    // حفظ الدفعة
    final paymentId = await paymentRepo.add(payment);
    
    // تحديث الدين
    final newPaidAmount = debt.paidAmount + params.amount;
    final newRemainingAmount = debt.originalAmount - newPaidAmount;
    final newStatus = newRemainingAmount <= 0 ? 'مسدد' : 
                      newPaidAmount > 0 ? 'دفع جزئي' : 'غير مسدد';
    
    final updatedDebt = Debt(
      id: debt.id,
      personType: debt.personType,
      personId: debt.personId,
      personName: debt.personName,
      transactionType: debt.transactionType,
      transactionId: debt.transactionId,
      originalAmount: debt.originalAmount,
      paidAmount: newPaidAmount,
      remainingAmount: newRemainingAmount,
      date: debt.date,
      dueDate: debt.dueDate,
      status: newStatus,
      lastPaymentDate: payment.paymentDate,
      notes: debt.notes,
    );
    
    await debtRepo.update(updatedDebt);
    
    // TODO: إنشاء إيصال سداد
    // TODO: إشعار العميل
    
    return paymentId;
  }
}

/// معاملات سداد دين
class PayDebtParams {
  final int debtId;
  final double amount;
  final String? paymentDate;
  final String? paymentTime;
  final String paymentMethod;
  final String? notes;
  
  const PayDebtParams({
    required this.debtId,
    required this.amount,
    this.paymentDate,
    this.paymentTime,
    this.paymentMethod = 'نقد',
    this.notes,
  });
}
