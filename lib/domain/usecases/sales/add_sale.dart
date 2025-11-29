// ignore_for_file: public_member_api_docs

import '../../entities/sale.dart';
import '../../entities/debt.dart';
import '../../repositories/sales_repository.dart';
import '../../repositories/debt_repository.dart';
import '../../repositories/customer_repository.dart';
import '../base/base_usecase.dart';

class AddSale implements UseCase<int, Sale> {
  final SalesRepository repo;
  final DebtRepository debtRepo;
  final CustomerRepository customerRepo;

  AddSale(this.repo, this.debtRepo, this.customerRepo);

  @override
  Future<int> call(Sale params) async {
    // حفظ عملية البيع
    final saleId = await repo.add(params);

    // إذا كان البيع لعميل وغير مدفوع بالكامل، ننشئ ديناً للعميل
    if (params.customerId != null && params.remainingAmount > 0) {
      final customerId = params.customerId!;

      // التحقق من وجود العميل
      final customer = await customerRepo.getById(customerId);
      if (customer != null) {
        // التحقق من حد الائتمان قبل إنشاء الدين
        if (customer.creditLimit > 0) {
          final totalDebt = customer.currentDebt + params.remainingAmount;
          if (totalDebt > customer.creditLimit) {
            // في حال تجاوز الحد، لا ننشئ ديناً ونكتفي بحفظ البيع
            return saleId;
          }
        }

        final status = params.paidAmount > 0 ? 'دفع جزئي' : 'غير مسدد';

        final debt = Debt(
          personType: 'عميل',
          personId: customerId,
          personName: params.customerName ?? customer.name,
          transactionType: 'بيع',
          transactionId: saleId,
          originalAmount: params.remainingAmount,
          paidAmount: 0,
          remainingAmount: params.remainingAmount,
          date: params.date,
          dueDate: params.dueDate,
          status: status,
          notes: params.notes,
        );

        await debtRepo.add(debt);
        await customerRepo.updateDebt(customerId, params.remainingAmount);
      }
    }

    return saleId;
  }
}
