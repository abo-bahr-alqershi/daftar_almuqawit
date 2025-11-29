// ignore_for_file: public_member_api_docs

import '../../entities/purchase.dart';
import '../../entities/debt.dart';
import '../../repositories/purchase_repository.dart';
import '../../repositories/debt_repository.dart';
import '../../repositories/supplier_repository.dart';
import '../base/base_usecase.dart';

/// تحديث فاتورة شراء مع مزامنة الديون المرتبطة بالمورد
class UpdatePurchase implements UseCase<void, Purchase> {
  final PurchaseRepository repo;
  final DebtRepository debtRepo;
  final SupplierRepository supplierRepo;

  UpdatePurchase(this.repo, this.debtRepo, this.supplierRepo);

  @override
  Future<void> call(Purchase updated) async {
    // إذا لم يكن هناك رقم للفاتورة، نكتفي بالتحديث العادي
    if (updated.id == null) {
      await repo.update(updated);
      return;
    }

    // في حال عدم وجود مورد، لا يوجد دين للمورد
    if (updated.supplierId == null) {
      await repo.update(updated);
      return;
    }

    final supplierId = updated.supplierId!;

    // جلب الدين المرتبط بهذه الفاتورة (إن وجد)
    final supplierDebts = await debtRepo.getByPerson('مورد', supplierId);
    Debt? purchaseDebt;
    for (final d in supplierDebts) {
      if (d.transactionType == 'شراء' && d.transactionId == updated.id) {
        purchaseDebt = d;
        break;
      }
    }

    // تحديث الفاتورة أولاً
    await repo.update(updated);

    // إجمالي المبلغ غير المسدد بناءً على الفاتورة والمدفوع عند الإنشاء
    if (purchaseDebt != null) {
      final oldRemaining = purchaseDebt.remainingAmount;
      final creditPayments = purchaseDebt.paidAmount; // مجموع دفعات الدين المسجلة

      // المبلغ الجديد غير المسدد (إجمالي الفاتورة - المدفوع عند الفاتورة - دفعات الدين)
      double newOutstanding =
          (updated.totalAmount - updated.paidAmount) - creditPayments;
      if (newOutstanding < 0) newOutstanding = 0;

      final newOriginalAmount = creditPayments + newOutstanding;

      String newStatus;
      if (newOutstanding <= 0) {
        newStatus = 'مسدد';
      } else if (creditPayments > 0) {
        newStatus = 'دفع جزئي';
      } else {
        newStatus = 'غير مسدد';
      }

      final updatedDebt = Debt(
        id: purchaseDebt.id,
        personType: purchaseDebt.personType,
        personId: purchaseDebt.personId,
        personName: purchaseDebt.personName,
        transactionType: purchaseDebt.transactionType,
        transactionId: purchaseDebt.transactionId,
        originalAmount: newOriginalAmount,
        paidAmount: creditPayments,
        remainingAmount: newOutstanding,
        date: purchaseDebt.date,
        dueDate: updated.dueDate ?? purchaseDebt.dueDate,
        status: newStatus,
        lastPaymentDate: purchaseDebt.lastPaymentDate,
        notes: purchaseDebt.notes,
      );

      await debtRepo.update(updatedDebt);

      final delta = newOutstanding - oldRemaining;
      if (delta != 0) {
        await supplierRepo.updateTotalDebt(supplierId, delta);
      }
    } else {
      // لم يكن هناك دين سابق، لكن الفاتورة أصبحت آجل الآن
      final newOutstanding = updated.totalAmount - updated.paidAmount;
      if (newOutstanding > 0) {
        final status = updated.paidAmount > 0 ? 'دفع جزئي' : 'غير مسدد';

        final newDebt = Debt(
          personType: 'مورد',
          personId: supplierId,
          personName: updated.supplierName ?? '',
          transactionType: 'شراء',
          transactionId: updated.id,
          originalAmount: newOutstanding,
          paidAmount: 0,
          remainingAmount: newOutstanding,
          date: updated.date,
          dueDate: updated.dueDate,
          status: status,
          notes: updated.notes,
        );

        await debtRepo.add(newDebt);
        await supplierRepo.updateTotalDebt(supplierId, newOutstanding);
      }
    }
  }
}
