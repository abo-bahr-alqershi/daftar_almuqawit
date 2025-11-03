// ignore_for_file: public_member_api_docs

import '../../entities/sale.dart';
import '../../repositories/sales_repository.dart';
import '../base/base_usecase.dart';

/// حالة استخدام البيع السريع
class QuickSale implements UseCase<int, QuickSaleParams> {
  final SalesRepository repo;
  
  QuickSale(this.repo);
  
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
    double? profit;
    if (params.costPrice != null) {
      profit = totalAmount - (params.costPrice! * params.quantity);
    }
    
    // إنشاء كيان البيع
    final sale = Sale(
      date: DateTime.now().toIso8601String().split('T')[0],
      time: DateTime.now().toIso8601String().split('T')[1].split('.')[0],
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
    );
    
    // حفظ البيع
    return await repo.add(sale);
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
