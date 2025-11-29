// ignore_for_file: public_member_api_docs

import '../../entities/purchase.dart';
import '../../entities/debt.dart';
import '../../repositories/purchase_repository.dart';
import '../../repositories/debt_repository.dart';
import '../../repositories/supplier_repository.dart';
import '../base/base_usecase.dart';

class AddPurchase implements UseCase<int, Purchase> {
  final PurchaseRepository repo;
  final DebtRepository debtRepo;
  final SupplierRepository supplierRepo;

  AddPurchase(this.repo, this.debtRepo, this.supplierRepo);

  @override
  Future<int> call(Purchase params) async {
    // حفظ عملية الشراء
    final purchaseId = await repo.add(params);

    // إذا كانت الفاتورة على مورد وغير مدفوعة بالكامل، ننشئ ديناً للمورد
    if (params.supplierId != null && !params.isPaid && params.remainingAmount > 0) {
      final status = params.paidAmount > 0 ? 'دفع جزئي' : 'غير مسدد';

      final debt = Debt(
        personType: 'مورد',
        personId: params.supplierId!,
        personName: params.supplierName ?? '',
        transactionType: 'شراء',
        transactionId: purchaseId,
        originalAmount: params.remainingAmount,
        paidAmount: 0,
        remainingAmount: params.remainingAmount,
        date: params.date,
        dueDate: params.dueDate,
        status: status,
        notes: params.notes,
      );

      await debtRepo.add(debt);
      await supplierRepo.updateTotalDebt(params.supplierId!, params.remainingAmount);
    }

    return purchaseId;
  }
}
