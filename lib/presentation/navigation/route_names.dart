// ignore_for_file: public_member_api_docs

/// أسماء المسارات (Routes) الموحّدة
class RouteNames {
  RouteNames._();

  static const String splash = '/';
  static const String home = '/home';

  // Auth routes
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String setup = '/setup';

  // Features
  static const String suppliers = '/suppliers';
  static const String customers = '/customers';
  static const String qatTypes = '/qat_types';
  static const String purchases = '/purchases';
  static const String sales = '/sales';
  static const String debts = '/debts';
  static const String debtPayments = '/debt_payments';
  static const String expenses = '/expenses';
  static const String accounts = '/accounts';
  static const String accounting = '/accounting';
  static const String statistics = '/statistics';
  static const String settings = '/settings';
  
  // Reports routes
  static const String reports = '/reports';
  static const String dailyReport = '/reports/daily';
  static const String weeklyReport = '/reports/weekly';
  static const String monthlyReport = '/reports/monthly';
  static const String yearlyReport = '/reports/yearly';
  static const String customReport = '/reports/custom';
}
