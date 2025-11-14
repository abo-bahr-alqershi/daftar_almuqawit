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
    
    print('📊 [GetDailyStatistics] جاري جلب إحصائيات اليوم: $date');
    
    // محاولة جلب الإحصائيات المحفوظة
    final existing = await statsRepo.getDaily(date);
    if (existing != null && !params.forceRefresh) {
      print('✅ [GetDailyStatistics] تم العثور على إحصائيات محفوظة');
      print('   - المبيعات: ${existing.totalSales}');
      print('   - المشتريات: ${existing.totalPurchases}');
      print('   - المصروفات: ${existing.totalExpenses}');
      print('   - صافي الربح: ${existing.netProfit}');
      return existing;
    }
    
    print('🔄 [GetDailyStatistics] إعادة حساب الإحصائيات من البيانات الخام...');
    
    // جمع بيانات اليوم
    final sales = await salesRepo.getByDate(date);
    final purchases = await purchaseRepo.getByDate(date);
    final expenses = await expenseRepo.getByDate(date);
    
    print('📦 [GetDailyStatistics] عدد السجلات:');
    print('   - المبيعات: ${sales.length}');
    print('   - المشتريات: ${purchases.length}');
    print('   - المصروفات: ${expenses.length}');
    
    // حساب المجاميع
    final totalSales = sales.fold<double>(0, (sum, sale) => sum + sale.totalAmount);
    final totalPurchases = purchases.fold<double>(0, (sum, purchase) => sum + purchase.totalAmount);
    final totalExpenses = expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
    
    print('💰 [GetDailyStatistics] المجاميع المحسوبة:');
    print('   - إجمالي المبيعات: $totalSales');
    print('   - إجمالي المشتريات: $totalPurchases');
    print('   - إجمالي المصروفات: $totalExpenses');
    
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
    // إذا كان الربح مخزن في قاعدة البيانات، استخدمه
    // وإلا احسبه من الفرق بين سعر البيع وسعر التكلفة
    double grossProfit = 0;
    
    print('💵 [GetDailyStatistics] تفاصيل حساب الربح:');
    for (final sale in sales) {
      double saleProfit;
      
      if (sale.profit > 0) {
        // استخدام الربح المخزن
        saleProfit = sale.profit;
        print('   ✓ بيع #${sale.id}: ربح مخزن = $saleProfit');
      } else {
        // حساب الربح من الفرق بين السعر والتكلفة
        final revenue = sale.totalAmount - sale.discount;
        final cost = sale.costPrice * sale.quantity;
        saleProfit = revenue - cost;
        print('   ⚙ بيع #${sale.id}: الإيراد=$revenue - التكلفة=$cost = $saleProfit');
        print('      (المبلغ=${sale.totalAmount}, الخصم=${sale.discount}, سعر التكلفة=${sale.costPrice}, الكمية=${sale.quantity})');
      }
      
      grossProfit += saleProfit;
    }
    
    final netProfit = grossProfit - totalExpenses;
    
    print('📈 [GetDailyStatistics] الأرباح المحسوبة:');
    print('   - إجمالي الربح: $grossProfit');
    print('   - صافي الربح: $netProfit');
    
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
    
    print('✅ [GetDailyStatistics] تم حفظ الإحصائيات بنجاح');
    
    // المقارنة مع الأيام السابقة إذا طلب ذلك
    if (params.includeComparison) {
      final yesterday = DateTime.parse(date).subtract(const Duration(days: 1));
      final yesterdayStats = await statsRepo.getDaily(yesterday.toIso8601String().split('T')[0]);
      
      if (yesterdayStats != null) {
        // حساب نسب التغيير
        final salesChange = totalSales - yesterdayStats.totalSales;
        final salesChangePercent = yesterdayStats.totalSales > 0 
            ? (salesChange / yesterdayStats.totalSales * 100)
            : 0.0;
        
        final profitChange = netProfit - yesterdayStats.netProfit;
        final profitChangePercent = yesterdayStats.netProfit > 0
            ? (profitChange / yesterdayStats.netProfit * 100)
            : 0.0;
        
        final expensesChange = totalExpenses - yesterdayStats.totalExpenses;
        final expensesChangePercent = yesterdayStats.totalExpenses > 0
            ? (expensesChange / yesterdayStats.totalExpenses * 100)
            : 0.0;
        
        // يمكن إضافة هذه البيانات إلى نموذج منفصل للمقارنة
        // أو توسيع نموذج DailyStatistics ليشمل بيانات المقارنة
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
