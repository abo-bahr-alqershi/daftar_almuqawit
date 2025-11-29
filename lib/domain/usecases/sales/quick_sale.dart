// ignore_for_file: public_member_api_docs

import '../../entities/sale.dart';
import '../../entities/debt.dart';
import '../../repositories/sales_repository.dart';
import '../../repositories/debt_repository.dart';
import '../../repositories/customer_repository.dart';
import '../base/base_usecase.dart';

/// حالة استخدام البيع السريع
class QuickSale implements UseCase<int, QuickSaleParams> {
  final SalesRepository repo;
  final DebtRepository debtRepo;
  final CustomerRepository customerRepo;
  
  QuickSale(this.repo, this.debtRepo, this.customerRepo);
  
  @override
  Future<int> call(QuickSaleParams params) async {
    // حساب المجموع
    final totalAmount = params.quantity * params.unitPrice;
    
    // حساب المبلغ المتبقي
    final remainingAmount = totalAmount - params.paidAmount;
    
    // تحديد حالة الدفع
    String paymentStatus;
    if (params.paidAmount >= totalAmount) {
      paymentStatus = 'مدفوع';
    } else if (params.paidAmount > 0) {
      paymentStatus = 'دفع جزئي';
    } else {
      paymentStatus = 'آجل';
    }
    
    // حساب الربح (إذا تم توفير سعر التكلفة)
    double profit = 0.0;
    if (params.costPrice != null) {
      profit = totalAmount - (params.costPrice! * params.quantity);
    }
    
    final now = DateTime.now();
    final dateStr = now.toIso8601String().split('T')[0];
    final timeStr = now.toIso8601String().split('T')[1].split('.')[0];

    // إنشاء كيان البيع
    final sale = Sale(
      date: dateStr,
      time: timeStr,
      customerId: params.customerId,
      qatTypeId: params.qatTypeId,
      quantity: params.quantity,
      unit: params.unit,
      unitPrice: params.unitPrice,
      totalAmount: totalAmount,
      paymentStatus: paymentStatus,
      paidAmount: params.paidAmount,
      remainingAmount: remainingAmount,
      profit: profit,
      notes: params.notes,
      isQuickSale: true,
    );
    
    // حفظ البيع
    final saleId = await repo.add(sale);

    // إذا كان البيع السريع لعميل وغير مدفوع بالكامل، ننشئ ديناً له
    if (params.customerId != null && remainingAmount > 0) {
      final customerId = params.customerId!;

      final customer = await customerRepo.getById(customerId);
      if (customer != null) {
        // التحقق من حد الائتمان
        if (customer.creditLimit > 0) {
          final totalDebt = customer.currentDebt + remainingAmount;
          if (totalDebt > customer.creditLimit) {
            // إذا تم تجاوز الحد، لا ننشئ ديناً إضافياً
            return saleId;
          }
        }

        final status = params.paidAmount > 0 ? 'دفع جزئي' : 'غير مسدد';

        final debt = Debt(
          personType: 'عميل',
          personId: customerId,
          personName: customer.name,
          transactionType: 'بيع',
          transactionId: saleId,
          originalAmount: remainingAmount,
          paidAmount: 0,
          remainingAmount: remainingAmount,
          date: dateStr,
          dueDate: null,
          status: status,
          notes: params.notes,
        );

        await debtRepo.add(debt);
        await customerRepo.updateDebt(customerId, remainingAmount);
      }
    }

    return saleId;
  }
}

/// معاملات البيع السريع
class QuickSaleParams {
  final int? customerId;
  final int? qatTypeId;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double paidAmount;
  final double? costPrice;
  final String? notes;
  
  const QuickSaleParams({
    this.customerId,
    this.qatTypeId,
    required this.quantity,
    this.unit = 'ربطة',
    required this.unitPrice,
    this.paidAmount = 0,
    this.costPrice,
    this.notes,
  });
}
