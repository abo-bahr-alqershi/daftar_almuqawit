/// إدارة التوجيه والملاحة في التطبيق
/// يعرف جميع المسارات ويدير التنقل بين الشاشات مع حماية المسارات

import 'package:flutter/material.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/purchase.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/activities_screen.dart';
import '../screens/home/dashboard_screen.dart';
import 'route_names.dart';
import '../screens/suppliers/suppliers_screen.dart';
import '../screens/customers/customers_screen.dart';
import '../screens/qat_types/qat_types_screen.dart';
import '../screens/qat_types/add_qat_type_screen.dart';
import '../screens/qat_types/edit_qat_type_screen.dart';
import '../screens/qat_types/qat_type_details_screen.dart';
import '../screens/purchases/purchases_screen.dart';
import '../screens/purchases/add_purchase_screen.dart';
import '../screens/purchases/edit_purchase_screen.dart';
import '../screens/purchases/purchase_details_screen.dart';
import '../screens/sales/sales_screen.dart';
import '../screens/sales/add_sale_screen.dart';
import '../screens/sales/quick_sale_screen.dart';
import '../screens/sales/sale_details_screen.dart';
import '../screens/sales/today_sales_screen.dart';
import '../screens/debts/debts_screen.dart';
import '../screens/debt_payments/debt_payments_screen.dart';
import '../screens/debt_payments/add_debt_payment_screen.dart';
import '../screens/expenses/expenses_screen.dart';
import '../screens/expenses/add_expense_screen.dart';
import '../screens/expenses/edit_expense_screen.dart';
import '../screens/expenses/expense_details_screen.dart';
import '../screens/accounting/accounting_screen.dart';
import '../screens/statistics/statistics_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/reports/daily_report_screen.dart';
import '../screens/reports/weekly_report_screen.dart';
import '../screens/reports/monthly_report_screen.dart';
import '../screens/reports/yearly_report_screen.dart';
import '../screens/reports/custom_report_screen.dart';
import '../screens/reports/profit_analysis_screen.dart';
import '../screens/reports/customers_report_screen.dart';
import '../screens/reports/products_report_screen.dart';
import '../screens/inventory/inventory_screen.dart';
import '../screens/inventory/add_return_screen.dart';
import '../screens/inventory/add_damaged_item_screen.dart';

/// مدير التوجيه الرئيسي للتطبيق
class AppRouter {
  /// حالة المصادقة
  static bool _isAuthenticated = false;

  /// تعيين حالة المصادقة
  static void setAuthenticated(bool value) {
    _isAuthenticated = value;
  }

  /// توليد المسارات مع حماية
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    // التحقق من المصادقة للمسارات المحمية
    if (_requiresAuth(settings.name) && !_isAuthenticated) {
      return MaterialPageRoute(builder: (_) => const SplashScreen());
    }

    switch (settings.name) {
      case RouteNames.splash:
        return _buildRoute(const SplashScreen());
      case RouteNames.home:
        return _buildRoute(const HomeScreen());
      case RouteNames.dashboard:
        return _buildRoute(const DashboardScreen());
      case RouteNames.activities:
        return _buildRoute(const ActivitiesScreen());
      case RouteNames.suppliers:
        return _buildRoute(const SuppliersScreen());
      case RouteNames.customers:
        return _buildRoute(const CustomersScreen());
      case RouteNames.qatTypes:
        return _buildRoute(const QatTypesScreen());
      case RouteNames.addQatType:
        return _buildRoute(const AddQatTypeScreen(), settings: settings);
      case RouteNames.editQatType:
        final qatType = settings.arguments as dynamic;
        return _buildRoute(EditQatTypeScreen(qatType: qatType));
      case RouteNames.qatTypeDetails:
        final qatTypeId = settings.arguments as int;
        return _buildRoute(QatTypeDetailsScreen(qatTypeId: qatTypeId));
      case RouteNames.purchases:
        return _buildRoute(const PurchasesScreen());
      case RouteNames.addPurchase:
        return _buildRoute(const AddPurchaseScreen());
      case RouteNames.editPurchase:
        final purchase = settings.arguments as Purchase;
        return _buildRoute(EditPurchaseScreen(purchase: purchase));
      case RouteNames.purchaseDetails:
        final purchase = settings.arguments as dynamic;
        return _buildRoute(PurchaseDetailsScreen(purchase: purchase));
      case RouteNames.sales:
        return _buildRoute(const SalesScreen());
      case RouteNames.addSale:
        return _buildRoute(const AddSaleScreen());
      case RouteNames.quickSale:
        return _buildRoute(const QuickSaleScreen());
      case RouteNames.saleDetails:
        final sale = settings.arguments as dynamic;
        return _buildRoute(SaleDetailsScreen(sale: sale));
      case RouteNames.todaySales:
        return _buildRoute(const TodaySalesScreen());
      case RouteNames.inventory:
        return _buildRoute(const InventoryScreen());
      case RouteNames.addReturn:
        return _buildRoute(const AddReturnScreen());
      case RouteNames.addDamagedItem:
        return _buildRoute(const AddDamagedItemScreen());
      case RouteNames.debts:
        return _buildRoute(const DebtsScreen());
      case RouteNames.debtPayments:
        final debtId = settings.arguments as int;
        return _buildRoute(DebtPaymentsScreen(debtId: debtId));
      case RouteNames.addDebtPayment:
        final debtId = settings.arguments as int?;
        return _buildRoute(AddDebtPaymentScreen(debtId: debtId ?? 0));
      case RouteNames.expenses:
        return _buildRoute(const ExpensesScreen());
      case RouteNames.addExpense:
        return _buildRoute(const AddExpenseScreen());
      case RouteNames.editExpense:
        final expense = settings.arguments as Expense;
        return _buildRoute(EditExpenseScreen(expense: expense));
      case RouteNames.expenseDetails:
        final expense = settings.arguments as Expense;
        return _buildRoute(ExpenseDetailsScreen(expense: expense));
      case RouteNames.accounts:
        return _buildRoute(const AccountingScreen());
      case RouteNames.accounting:
        return _buildRoute(const AccountingScreen());
      case RouteNames.statistics:
        return _buildRoute(const StatisticsScreen());
      case RouteNames.settings:
        return _buildRoute(const SettingsScreen());
      case RouteNames.reports:
        return _buildRoute(const ReportsScreen());
      case RouteNames.dailyReport:
        return _buildRoute(const DailyReportScreen());
      case RouteNames.weeklyReport:
        return _buildRoute(const WeeklyReportScreen());
      case RouteNames.monthlyReport:
        return _buildRoute(const MonthlyReportScreen());
      case RouteNames.yearlyReport:
        return _buildRoute(const YearlyReportScreen());
      case RouteNames.customReport:
        return _buildRoute(const CustomReportScreen());
      case RouteNames.profitAnalysis:
        return _buildRoute(const ProfitAnalysisScreen());
      case RouteNames.customersReport:
        return _buildRoute(const CustomersReportScreen());
      case RouteNames.productsReport:
        return _buildRoute(const ProductsReportScreen());
      default:
        return _buildRoute(const SplashScreen());
    }
  }

  /// بناء المسار مع انتقال مخصص
  static Route<dynamic> _buildRoute(Widget screen, {bool fade = false, RouteSettings? settings}) {
    if (fade) {
      return PageRouteBuilder(
        settings: settings,
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      );
    }
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => screen,
    );
  }

  /// التحقق من أن المسار يتطلب مصادقة
  static bool _requiresAuth(String? routeName) {
    const publicRoutes = [RouteNames.splash];
    return !publicRoutes.contains(routeName);
  }

  /// معالجة Deep Links
  static Route<dynamic>? handleDeepLink(Uri uri) {
    // TODO: تطبيق معالجة Deep Links
    return null;
  }
}
