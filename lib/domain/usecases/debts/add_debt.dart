/// حالة استخدام إضافة دين جديد
/// تتحقق من البيانات وتربط الدين بالعميل وتحدد جدول السداد

import '../../entities/debt.dart';
import '../../repositories/debt_repository.dart';
import '../../repositories/customer_repository.dart';
import '../base/base_usecase.dart';

/// حالة استخدام إضافة دين
class AddDebt implements UseCase<int, AddDebtParams> {
  final DebtRepository debtRepo;
  final CustomerRepository customerRepo;
  
  AddDebt(this.debtRepo, this.customerRepo);
  
  @override
  Future<int> call(AddDebtParams params) async {
    // التحقق من صحة البيانات
    if (params.amount <= 0) {
      throw ArgumentError('مبلغ الدين يجب أن يكون أكبر من صفر');
    }
    
    // التحقق من وجود العميل
    final customer = await customerRepo.getById(params.customerId);
    if (customer == null) {
      throw StateError('العميل غير موجود');
    }
    
    // التحقق من حد الائتمان
    if (customer.creditLimit > 0) {
      final totalDebt = customer.currentDebt + params.amount;
      if (totalDebt > customer.creditLimit) {
        throw StateError('تجاوز حد الائتمان المسموح للعميل');
      }
    }
    
    // حساب تاريخ الاستحقاق
    final dueDate = params.dueDate ?? 
        DateTime.now().add(Duration(days: params.dueDays ?? 30));
    
    // إنشاء الدين
    final debt = Debt(
      personType: 'عميل',
      personId: params.customerId,
      personName: customer.name,
      transactionType: params.transactionType,
      transactionId: params.transactionId,
      originalAmount: params.amount,
      paidAmount: 0,
      remainingAmount: params.amount,
      date: DateTime.now().toIso8601String().split('T')[0],
      dueDate: dueDate.toIso8601String().split('T')[0],
      status: 'غير مسدد',
      notes: params.notes,
    );
    
    // حفظ الدين
    final debtId = await debtRepo.add(debt);
    
    // إنشاء تذكيرات للسداد
    if (dueDate.isAfter(DateTime.now())) {
      final daysBefore = dueDate.difference(DateTime.now()).inDays;
      
      if (daysBefore >= 3) {
        // تذكير قبل 3 أيام من الاستحقاق
        // يمكن استخدام notification service أو جدولة محلية
      }
      
      if (daysBefore >= 1) {
        // تذكير قبل يوم من الاستحقاق
      }
      
      // تذكير في يوم الاستحقاق
    }
    
    return debtId;
  }
}

/// معاملات إضافة دين
class AddDebtParams {
  final int customerId;
  final double amount;
  final String? transactionType;
  final int? transactionId;
  final DateTime? dueDate;
  final int? dueDays;
  final String? notes;
  
  const AddDebtParams({
    required this.customerId,
    required this.amount,
    this.transactionType,
    this.transactionId,
    this.dueDate,
    this.dueDays,
    this.notes,
  });
}
