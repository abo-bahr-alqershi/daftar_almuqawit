// ignore_for_file: public_member_api_docs

/// أسماء المسارات (Routes) الموحّدة
class RouteNames {
  RouteNames._();

  // ========== Main Routes ==========
  static const String splash = '/';
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String activities = '/activities';

  // ========== Auth Routes ==========
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String setup = '/setup';

  // ========== Suppliers Routes ==========
  static const String suppliers = '/suppliers';
  static const String suppliersList = '/suppliers/list';
  static const String addSupplier = '/suppliers/add';
  static const String editSupplier = '/suppliers/edit';
  static const String supplierDetails = '/suppliers/details';

  // ========== Customers Routes ==========
  static const String customers = '/customers';
  static const String customersList = '/customers/list';
  static const String addCustomer = '/customers/add';
  static const String editCustomer = '/customers/edit';
  static const String customerDetails = '/customers/details';
  static const String blockedCustomers = '/customers/blocked';

  // ========== Qat Types Routes ==========
  static const String qatTypes = '/qat_types';
  static const String addQatType = '/qat_types/add';
  static const String editQatType = '/qat_types/edit';
  static const String qatTypeDetails = '/qat_types/details';

  // ========== Purchases Routes ==========
  static const String purchases = '/purchases';
  static const String addPurchase = '/purchases/add';
  static const String editPurchase = '/purchases/edit';
  static const String purchaseDetails = '/purchases/details';

  // ========== Sales Routes ==========
  static const String sales = '/sales';
  static const String addSale = '/sales/add';
  static const String saleDetails = '/sales/details';
  static const String quickSale = '/sales/quick';

  // ========== Inventory Routes  // المخزون
  static const String inventory = '/inventory';
  
  // المردودات
  static const String returns = '/returns';
  static const String addReturn = '/add-return';
  static const String returnDetails = '/return-details';
  
  // البضاعة التالفة
  static const String damagedItems = '/damaged-items';
  static const String addDamagedItem = '/add-damaged-item';
  static const String damageDetails = '/damage-details';
  static const String inventoryList = '/inventory/list';
  static const String inventoryDetails = '/inventory/details';
  static const String inventoryTransactions = '/inventory/transactions';
  static const String inventoryAdjustment = '/inventory/adjustment';
  static const String inventoryStats = '/inventory/statistics';
  static const String todaySales = '/sales/today';

  // ========== Debts Routes ==========
  static const String debts = '/debts';
  static const String addDebt = '/debts/add';
  static const String debtDetails = '/debts/details';
  static const String debtPayment = '/debts/payment';
  static const String overdueDebts = '/debts/overdue';
  static const String debtPayments = '/debt_payments';

  // ========== Expenses Routes ==========
  static const String expenses = '/expenses';
  static const String addExpense = '/expenses/add';
  static const String expenseCategories = '/expenses/categories';

  // ========== Accounting Routes ==========
  static const String accounts = '/accounts';
  static const String accounting = '/accounting';
  static const String cash = '/accounting/cash';
  static const String journalEntries = '/accounting/journal-entries';
  static const String addJournalEntry = '/accounting/journal-entries/add';

  // ========== Statistics Routes ==========
  static const String statistics = '/statistics';

  // ========== Reports Routes ==========
  static const String reports = '/reports';
  static const String dailyReport = '/reports/daily';
  static const String weeklyReport = '/reports/weekly';
  static const String monthlyReport = '/reports/monthly';
  static const String yearlyReport = '/reports/yearly';
  static const String customReport = '/reports/custom';

  // ========== Settings Routes ==========
  static const String settings = '/settings';
  static const String profile = '/settings/profile';
  static const String theme = '/settings/theme';
  static const String language = '/settings/language';
  static const String backup = '/settings/backup';
  static const String about = '/settings/about';
}
