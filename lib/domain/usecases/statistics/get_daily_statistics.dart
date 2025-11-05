/// حالة استخدام الحصول على الإحصائيات اليومية
/// تجمع بيانات اليوم وتحسب المجاميع والأرباح والمقارنات

import '../../entities/daily_statistics.dart';
import '../../repositories/statistics_repository.dart';
import '../../repositories/sales_repository.dart';
import '../../repositories/purchase_repository.dart';
import '../../repositories/expense_repository.dart';
import '../base/base_usecase.dart';

/// حالة استخدام الإحصائيات اليومية
class GetDailyStatistics implements UseCase<DailyStatistics, GetDailyStatisticsParams> {
  final StatisticsRepository statsRepo;
  final SalesRepository salesRepo;
  final PurchaseRepository purchaseRepo;
  final ExpenseRepository expenseRepo;
  
  GetDailyStatistics({
    required this.statsRepo,
    required this.salesRepo,
    required this.purchaseRepo,
    required this.expenseRepo,
  });
  
  @override
  Future<DailyStatistics> call(GetDailyStatisticsParams params) async {
    // التأريخ المطلوب
    final date = params.date;
    
    // محاولة جلب الإحصائيات المحفوظة
    final existing = await statsRepo.getDaily(date);
    if (existing != null && !params.forceRefresh) {
      return existing;
    }
    
    // جمع بيانات اليوم
    final sales = await salesRepo.getByDate(date);
    final purchases = await purchaseRepo.getByDate(date);
    final expenses = await expenseRepo.getByDate(date);
    
    // حساب المجاميع
    final totalSales = sales.fold<double>(0, (sum, sale) => sum + sale.totalAmount);
    final totalPurchases = purchases.fold<double>(0, (sum, purchase) => sum + purchase.totalAmount);
    final totalExpenses = expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
    
    // حساب المبيعات النقدية والآجلة
    final cashSales = sales
        .where((s) => s.paymentStatus == 'مدفوع')
        .fold<double>(0, (sum, sale) => sum + sale.totalAmount);
    final creditSales = totalSales - cashSales;
    
    // حساب الديون الجديدة والمحصلة
    final newDebts = sales
        .where((s) => s.paymentStatus != 'مدفوع')
        .fold<double>(0, (sum, sale) => sum + sale.remainingAmount);
    final collectedDebts = sales
        .fold<double>(0, (sum, sale) => sum + sale.paidAmount);
    
    // حساب الأرباح
    final grossProfit = sales.fold<double>(0, (sum, sale) => sum + (sale.profit ?? 0));
    final netProfit = grossProfit - totalExpenses;
    
    // حساب الرصيد النقدي
    final cashBalance = cashSales + collectedDebts - totalPurchases - totalExpenses;
    
    // إنشاء كيان الإحصائيات
    final statistics = DailyStatistics(
      date: date,
      totalPurchases: totalPurchases,
      totalSales: totalSales,
      totalExpenses: totalExpenses,
      cashSales: cashSales,
      creditSales: creditSales,
      grossProfit: grossProfit,
      netProfit: netProfit,
      newDebts: newDebts,
      collectedDebts: collectedDebts,
      cashBalance: cashBalance,
    );
    
    // حفظ الإحصائيات
    await statsRepo.saveDaily(statistics);
    
    // المقارنة مع الأيام السابقة إذا طلب ذلك
    if (params.includeComparison) {
      final yesterday = DateTime.parse(date).subtract(const Duration(days: 1));
      final yesterdayStats = await statsRepo.getDaily(yesterday.toIso8601String().split('T')[0]);
      
      if (yesterdayStats != null) {
        // TODO: إضافة بيانات المقارنة
      }
    }
    
    return statistics;
  }
}

/// معاملات الإحصائيات اليومية
class GetDailyStatisticsParams {
  final String date;
  final bool forceRefresh;
  final bool includeComparison;
  
  const GetDailyStatisticsParams({
    required this.date,
    this.forceRefresh = false,
    this.includeComparison = false,
  });
}
