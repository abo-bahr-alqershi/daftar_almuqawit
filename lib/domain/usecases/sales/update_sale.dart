// ignore_for_file: public_member_api_docs

import '../../entities/sale.dart';
import '../../entities/debt.dart';
import '../../repositories/sales_repository.dart';
import '../../repositories/debt_repository.dart';
import '../../repositories/customer_repository.dart';
import '../base/base_usecase.dart';

class UpdateSale implements UseCase<void, Sale> {
  final SalesRepository repo;
  final DebtRepository debtRepo;
  final CustomerRepository customerRepo;

  UpdateSale(this.repo, this.debtRepo, this.customerRepo);

  @override
  Future<void> call(Sale updated) async {
    if (updated.id == null) {
      await repo.update(updated);
      return;
    }

    // إذا لم يكن البيع مرتبطاً بعميل لا يوجد دين
    if (updated.customerId == null) {
      await repo.update(updated);
      return;
    }

    final customerId = updated.customerId!;

    // جلب الديون المرتبطة بهذا العميل
    final customerDebts = await debtRepo.getByPerson('عميل', customerId);
    Debt? saleDebt;
    for (final d in customerDebts) {
      if (d.transactionType == 'بيع' && d.transactionId == updated.id) {
        saleDebt = d;
        break;
      }
    }

    // تحديث البيع أولاً
    await repo.update(updated);

    // جلب بيانات العميل الحالية
    final customer = await customerRepo.getById(customerId);
    if (customer == null) return;

    if (saleDebt != null) {
      final oldRemaining = saleDebt.remainingAmount;
      final creditPayments = saleDebt.paidAmount; // دفعات الدين المسجلة

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
        id: saleDebt.id,
        personType: saleDebt.personType,
        personId: saleDebt.personId,
        personName: saleDebt.personName,
        transactionType: saleDebt.transactionType,
        transactionId: saleDebt.transactionId,
        originalAmount: newOriginalAmount,
        paidAmount: creditPayments,
        remainingAmount: newOutstanding,
        date: saleDebt.date,
        dueDate: updated.dueDate ?? saleDebt.dueDate,
        status: newStatus,
        lastPaymentDate: saleDebt.lastPaymentDate,
        notes: saleDebt.notes,
      );

      await debtRepo.update(updatedDebt);

      final delta = newOutstanding - oldRemaining;
      if (delta != 0) {
        await customerRepo.updateDebt(customerId, delta);
      }
    } else {
      // لم يكن هناك دين سابق، لكن البيع أصبح آجل الآن
      final newOutstanding = updated.totalAmount - updated.paidAmount;
      if (newOutstanding > 0) {
        // التحقق من حد الائتمان
        if (customer.creditLimit > 0) {
          final totalDebt = customer.currentDebt + newOutstanding;
          if (totalDebt > customer.creditLimit) {
            // نتجاهل إنشاء الدين إذا تجاوز الحد، مع الإبقاء على البيع
            return;
          }
        }

        final status = updated.paidAmount > 0 ? 'دفع جزئي' : 'غير مسدد';

        final newDebt = Debt(
          personType: 'عميل',
          personId: customerId,
          personName: updated.customerName ?? customer.name,
          transactionType: 'بيع',
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
        await customerRepo.updateDebt(customerId, newOutstanding);
      }
    }
  }
}
