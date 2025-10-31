// ignore_for_file: public_member_api_docs

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

/// مسؤول عن إنشاء المسارات والتنقل بينها
class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case RouteNames.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case RouteNames.suppliers:
        return MaterialPageRoute(builder: (_) => const SuppliersScreen());
      case RouteNames.customers:
        return MaterialPageRoute(builder: (_) => const CustomersScreen());
      case RouteNames.qatTypes:
        return MaterialPageRoute(builder: (_) => const QatTypesScreen());
      case RouteNames.purchases:
        return MaterialPageRoute(builder: (_) => const PurchasesScreen());
      case RouteNames.sales:
        return MaterialPageRoute(builder: (_) => const SalesScreen());
      case RouteNames.debts:
        return MaterialPageRoute(builder: (_) => const DebtsScreen());
      case RouteNames.debtPayments:
        return MaterialPageRoute(builder: (_) => const DebtPaymentsScreen());
      case RouteNames.expenses:
        return MaterialPageRoute(builder: (_) => const ExpensesScreen());
      case RouteNames.accounts:
        return MaterialPageRoute(builder: (_) => const AccountsScreen());
      case RouteNames.accounting:
        return MaterialPageRoute(builder: (_) => const AccountingScreen());
      case RouteNames.statistics:
        return MaterialPageRoute(builder: (_) => const StatisticsScreen());
      case RouteNames.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
