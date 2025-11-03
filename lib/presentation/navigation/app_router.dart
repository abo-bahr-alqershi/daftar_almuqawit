/// إدارة التوجيه والملاحة في التطبيق
/// يعرف جميع المسارات ويدير التنقل بين الشاشات مع حماية المسارات

import 'package:flutter/material.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/home/home_screen.dart';
import 'route_names.dart';
import '../screens/suppliers/suppliers_screen.dart';
import '../screens/customers/customers_screen.dart';
import '../screens/qat_types/qat_types_screen.dart';
import '../screens/purchases/purchases_screen.dart';
import '../screens/sales/sales_screen.dart';
import '../screens/debts/debts_screen.dart';
import '../screens/debt_payments/debt_payments_screen.dart';
import '../screens/expenses/expenses_screen.dart';
import '../screens/accounts/accounts_screen.dart';
import '../screens/accounting/accounting_screen.dart';
import '../screens/statistics/statistics_screen.dart';
import '../screens/settings/settings_screen.dart';

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
      case RouteNames.suppliers:
        return _buildRoute(const SuppliersScreen());
      case RouteNames.customers:
        return _buildRoute(const CustomersScreen());
      case RouteNames.qatTypes:
        return _buildRoute(const QatTypesScreen());
      case RouteNames.purchases:
        return _buildRoute(const PurchasesScreen());
      case RouteNames.sales:
        return _buildRoute(const SalesScreen());
      case RouteNames.debts:
        return _buildRoute(const DebtsScreen());
      case RouteNames.debtPayments:
        return _buildRoute(const DebtPaymentsScreen());
      case RouteNames.expenses:
        return _buildRoute(const ExpensesScreen());
      case RouteNames.accounts:
        return _buildRoute(const AccountsScreen());
      case RouteNames.accounting:
        return _buildRoute(const AccountingScreen());
      case RouteNames.statistics:
        return _buildRoute(const StatisticsScreen());
      case RouteNames.settings:
        return _buildRoute(const SettingsScreen());
      default:
        return _buildRoute(const SplashScreen());
    }
  }
  
  /// بناء المسار مع انتقال مخصص
  static Route<dynamic> _buildRoute(Widget screen, {bool fade = false}) {
    if (fade) {
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      );
    }
    return MaterialPageRoute(builder: (_) => screen);
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
