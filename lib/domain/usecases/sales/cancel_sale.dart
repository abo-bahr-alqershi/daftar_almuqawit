// ignore_for_file: public_member_api_docs

import '../../entities/debt.dart';
import '../../repositories/sales_repository.dart';
import '../../repositories/debt_repository.dart';
import '../../repositories/customer_repository.dart';
import '../base/base_usecase.dart';

/// إلغاء بيع مع تحديث ديون العميل المرتبطة به
class CancelSale implements UseCase<void, int> {
  final SalesRepository repo;
  final DebtRepository debtRepo;
  final CustomerRepository customerRepo;

  CancelSale(this.repo, this.debtRepo, this.customerRepo);

  @override
  Future<void> call(int id) async {
    // جلب البيع قبل الحذف لمعرفة العميل المرتبط
    final sale = await repo.getById(id);

    if (sale != null && sale.customerId != null) {
      final customerId = sale.customerId!;

      // البحث عن الدين المرتبط بهذا البيع (إن وجد)
      final customerDebts = await debtRepo.getByPerson('عميل', customerId);
      Debt? saleDebt;
      for (final d in customerDebts) {
        if (d.transactionType == 'بيع' && d.transactionId == id) {
          saleDebt = d;
          break;
        }
      }

      if (saleDebt != null) {
        final oldRemaining = saleDebt.remainingAmount;

        if (oldRemaining > 0) {
          // تصفير المبلغ المتبقي واعتبار الدين مسدداً محاسبياً
          final updatedDebt = Debt(
            id: saleDebt.id,
            personType: saleDebt.personType,
            personId: saleDebt.personId,
            personName: saleDebt.personName,
            transactionType: saleDebt.transactionType,
            transactionId: saleDebt.transactionId,
            originalAmount: saleDebt.originalAmount,
            paidAmount: saleDebt.paidAmount,
            remainingAmount: 0,
            date: saleDebt.date,
            dueDate: saleDebt.dueDate,
            status: 'مسدد',
            lastPaymentDate: saleDebt.lastPaymentDate,
            notes: saleDebt.notes,
          );

          await debtRepo.update(updatedDebt);
          await customerRepo.updateDebt(customerId, -oldRemaining);
        }
      }
    }

    // أخيراً، حذف البيع نفسه
    await repo.delete(id);
  }
}
