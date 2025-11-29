// ignore_for_file: public_member_api_docs

import '../../entities/debt.dart';
import '../../repositories/purchase_repository.dart';
import '../../repositories/debt_repository.dart';
import '../../repositories/supplier_repository.dart';
import '../base/base_usecase.dart';

/// إلغاء فاتورة شراء مع تحديث ديون المورد المرتبطة بها
class CancelPurchase implements UseCase<void, int> {
  final PurchaseRepository repo;
  final DebtRepository debtRepo;
  final SupplierRepository supplierRepo;

  CancelPurchase(this.repo, this.debtRepo, this.supplierRepo);

  @override
  Future<void> call(int id) async {
    // جلب الفاتورة قبل الحذف لمعرفة المورد المرتبط
    final purchase = await repo.getById(id);

    if (purchase != null && purchase.supplierId != null) {
      final supplierId = purchase.supplierId!;

      // البحث عن الدين المرتبط بهذه الفاتورة (إن وجد)
      final supplierDebts = await debtRepo.getByPerson('مورد', supplierId);
      Debt? purchaseDebt;
      for (final d in supplierDebts) {
        if (d.transactionType == 'شراء' && d.transactionId == id) {
          purchaseDebt = d;
          break;
        }
      }

      if (purchaseDebt != null) {
        final oldRemaining = purchaseDebt.remainingAmount;

        if (oldRemaining > 0) {
          // تصفير المبلغ المتبقي واعتبار الدين مسدداً محاسبياً
          final updatedDebt = Debt(
            id: purchaseDebt.id,
            personType: purchaseDebt.personType,
            personId: purchaseDebt.personId,
            personName: purchaseDebt.personName,
            transactionType: purchaseDebt.transactionType,
            transactionId: purchaseDebt.transactionId,
            originalAmount: purchaseDebt.originalAmount,
            paidAmount: purchaseDebt.paidAmount,
            remainingAmount: 0,
            date: purchaseDebt.date,
            dueDate: purchaseDebt.dueDate,
            status: 'مسدد',
            lastPaymentDate: purchaseDebt.lastPaymentDate,
            notes: purchaseDebt.notes,
          );

          await debtRepo.update(updatedDebt);
          await supplierRepo.updateTotalDebt(supplierId, -oldRemaining);
        }
      }
    }

    // أخيراً، حذف الفاتورة نفسها
    await repo.delete(id);
  }
}
