// Modules
import 'modules/database_module.dart';
import 'modules/firebase_module.dart';
import 'modules/repository_module.dart';
import 'modules/bloc_module.dart';
    // ignore_for_file: public_member_api_docs

import 'package:get_it/get_it.dart';

import '../../data/database/database_helper.dart';

// Services
import '../services/network/api_client.dart';
import '../services/network/connectivity_service.dart';
import '../services/network/network_service.dart';
import '../services/local/shared_preferences_service.dart';
import '../services/local/secure_storage_service.dart';
import '../services/local/cache_service.dart';
import '../services/backup_service.dart';
import '../services/firebase/firestore_service.dart';
import '../services/firebase/firebase_service.dart';
import '../services/export_service.dart';
import '../services/notification_service.dart';
import '../services/firebase/firebase_auth_service.dart';
import '../services/firebase/firebase_storage_service.dart';
import '../services/firebase/firebase_analytics_service.dart';
import '../services/share_service.dart';
import '../services/print_service.dart';
import '../services/logger_service.dart';
import '../services/sync/sync_service.dart';
import '../services/sync/sync_manager.dart';
import '../services/sync/conflict_resolver.dart';
import '../services/sync/sync_queue.dart';
import '../services/sync/offline_queue.dart';

// Local DataSources
// TODO: سيتم استخدامها عند تنفيذ setup() كاملاً
// import '../../data/datasources/local/supplier_local_datasource.dart';
// import '../../data/datasources/local/customer_local_datasource.dart';
// import '../../data/datasources/local/qat_type_local_datasource.dart';
// import '../../data/datasources/local/purchase_local_datasource.dart';
// import '../../data/datasources/local/sales_local_datasource.dart';
// import '../../data/datasources/local/debt_local_datasource.dart';
// import '../../data/datasources/local/debt_payment_local_datasource.dart';
// import '../../data/datasources/local/expense_local_datasource.dart';
// import '../../data/datasources/local/accounting_local_datasource.dart';
// import '../../data/datasources/local/statistics_local_datasource.dart';
// import '../../data/datasources/local/sync_local_datasource.dart';

// Remote DataSources
// TODO: سيتم استخدامها عند تنفيذ setup() كاملاً
// import '../../data/datasources/remote/suppliers_remote_datasource.dart';
// import '../../data/datasources/remote/customers_remote_datasource.dart';
// import '../../data/datasources/remote/qat_types_remote_datasource.dart';
// import '../../data/datasources/remote/purchases_remote_datasource.dart';
// import '../../data/datasources/remote/sales_remote_datasource.dart';
// import '../../data/datasources/remote/debts_remote_datasource.dart';
// import '../../data/datasources/remote/debt_payments_remote_datasource.dart';
// import '../../data/datasources/remote/expenses_remote_datasource.dart';
// import '../../data/datasources/remote/accounts_remote_datasource.dart';
// import '../../data/datasources/remote/journal_entries_remote_datasource.dart';
// import '../../data/datasources/remote/journal_entry_details_remote_datasource.dart';
// import '../../data/datasources/remote/daily_stats_remote_datasource.dart';

// Repositories impl
// TODO: سيتم استخدامها عند تنفيذ setup() كاملاً
// import '../../data/repositories/supplier_repository_impl.dart';
// import '../../data/repositories/customer_repository_impl.dart';
// import '../../data/repositories/qat_type_repository_impl.dart';
// import '../../data/repositories/purchase_repository_impl.dart';
// import '../../data/repositories/sale_repository_impl.dart';
// import '../../data/repositories/debt_repository_impl.dart';
// import '../../data/repositories/debt_payment_repository_impl.dart';
// import '../../data/repositories/expense_repository_impl.dart';
// import '../../data/repositories/accounting_repository_impl.dart';
// import '../../data/repositories/statistics_repository_impl.dart';
// import '../../data/repositories/sync_repository_impl.dart';
// import '../../data/repositories/backup_repository_impl.dart';

// Repositories interfaces
// TODO: سيتم استخدامها عند تنفيذ setup() كاملاً
// import '../../domain/repositories/supplier_repository.dart';
// import '../../domain/repositories/customer_repository.dart';
// import '../../domain/repositories/qat_type_repository.dart';
import '../../domain/repositories/purchase_repository.dart';
import '../../domain/repositories/sales_repository.dart';
import '../../domain/repositories/debt_repository.dart';
import '../../domain/repositories/debt_payment_repository.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/repositories/accounting_repository.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../../domain/repositories/sync_repository.dart';
import '../../domain/repositories/backup_repository.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../domain/repositories/supplier_repository.dart';

// UseCases
// TODO: سيتم استخدامها عند تنفيذ setup() كاملاً
// import '../../domain/usecases/base/base_usecase.dart';
// Suppliers
import '../../domain/usecases/suppliers/add_supplier.dart';
import '../../domain/usecases/suppliers/get_suppliers.dart';
import '../../domain/usecases/suppliers/update_supplier.dart';
import '../../domain/usecases/suppliers/delete_supplier.dart';
import '../../domain/usecases/suppliers/search_suppliers.dart';
// Customers
import '../../domain/usecases/customers/add_customer.dart';
import '../../domain/usecases/customers/get_customers.dart';
import '../../domain/usecases/customers/update_customer.dart';
import '../../domain/usecases/customers/delete_customer.dart';
import '../../domain/usecases/customers/search_customers.dart';
import '../../domain/usecases/customers/block_customer.dart';
import '../../domain/usecases/customers/get_customer_debts.dart';
import '../../domain/usecases/customers/get_customer_history.dart';
// Purchases
import '../../domain/usecases/purchases/add_purchase.dart';
import '../../domain/usecases/purchases/get_purchases.dart';
import '../../domain/usecases/purchases/get_today_purchases.dart';
import '../../domain/usecases/purchases/get_purchases_by_supplier.dart';
import '../../domain/usecases/purchases/update_purchase.dart';
import '../../domain/usecases/purchases/delete_purchase.dart';
import '../../domain/usecases/purchases/cancel_purchase.dart';
// Sales
import '../../domain/usecases/sales/add_sale.dart';
import '../../domain/usecases/sales/get_sales.dart';
import '../../domain/usecases/sales/get_today_sales.dart';
import '../../domain/usecases/sales/get_sales_by_customer.dart';
import '../../domain/usecases/sales/update_sale.dart';
import '../../domain/usecases/sales/delete_sale.dart';
import '../../domain/usecases/sales/quick_sale.dart';
import '../../domain/usecases/sales/cancel_sale.dart';
// Debts
import '../../domain/usecases/debts/add_debt.dart';
import '../../domain/usecases/debts/get_debts.dart';
import '../../domain/usecases/debts/get_pending_debts.dart';
import '../../domain/usecases/debts/get_overdue_debts.dart';
import '../../domain/usecases/debts/get_debts_by_person.dart';
import '../../domain/usecases/debts/update_debt.dart';
import '../../domain/usecases/debts/delete_debt.dart';
import '../../domain/usecases/debts/pay_debt.dart';
import '../../domain/usecases/debts/partial_payment.dart';
import '../../domain/usecases/debts/send_reminder.dart';
// Expenses
import '../../domain/usecases/expenses/add_expense.dart';
import '../../domain/usecases/expenses/get_daily_expenses.dart';
import '../../domain/usecases/expenses/get_expenses_by_category.dart';
import '../../domain/usecases/expenses/update_expense.dart';
import '../../domain/usecases/expenses/delete_expense.dart';
// Debt payments
import '../../domain/usecases/debt_payments/add_debt_payment.dart';
import '../../domain/usecases/debt_payments/get_debt_payments_by_debt.dart';
import '../../domain/usecases/debt_payments/update_debt_payment.dart';
import '../../domain/usecases/debt_payments/delete_debt_payment.dart';
// Accounting
import '../../domain/usecases/accounting/add_journal_entry.dart';
import '../../domain/usecases/accounting/add_journal_entry_detail.dart';
import '../../domain/usecases/accounting/get_journal_entry_details.dart';
import '../../domain/usecases/accounting/get_cash_balance.dart';
import '../../domain/usecases/accounting/close_daily_accounts.dart';
import '../../domain/usecases/accounting/get_trial_balance.dart';
import '../../domain/usecases/accounting/generate_financial_statements.dart';
// Statistics
import '../../domain/usecases/statistics/get_daily_statistics.dart';
import '../../domain/usecases/statistics/get_monthly_statistics.dart';
import '../../domain/usecases/statistics/get_weekly_report.dart';
import '../../domain/usecases/statistics/get_yearly_report.dart';
import '../../domain/usecases/statistics/get_profit_analysis.dart';
import '../../domain/usecases/statistics/get_best_sellers.dart';
import '../../domain/usecases/statistics/get_customer_ranking.dart';
// Qat types
import '../../domain/usecases/qat_types/add_qat_type.dart';
import '../../domain/usecases/qat_types/get_qat_types.dart';
import '../../domain/usecases/qat_types/get_qat_type_by_id.dart';
import '../../domain/usecases/qat_types/update_qat_type.dart';
import '../../domain/usecases/qat_types/delete_qat_type.dart';
// Sync
import '../../domain/usecases/sync/sync_all.dart';
import '../../domain/usecases/sync/check_sync_status.dart';
import '../../domain/usecases/sync/queue_operation.dart';
import '../../domain/usecases/sync/sync_data.dart';
import '../../domain/usecases/sync/resolve_conflicts.dart';
import '../../domain/usecases/sync/queue_offline_operation.dart';
// Backup
import '../../domain/usecases/backup/create_backup.dart';
import '../../domain/usecases/backup/export_to_excel.dart';
import '../../domain/usecases/backup/restore_backup.dart';
import '../../domain/usecases/backup/schedule_auto_backup.dart';
import '../../domain/usecases/reports/print_report.dart';
import '../../domain/usecases/reports/share_report.dart';

// Blocs
import '../../presentation/blocs/app/app_bloc.dart';
import '../../presentation/blocs/splash/splash_bloc.dart';
import '../../presentation/blocs/home/home_bloc.dart';
import '../../presentation/blocs/app/app_settings_bloc.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/sync/sync_bloc.dart';
import '../../presentation/blocs/home/dashboard_bloc.dart';
import '../../presentation/blocs/suppliers/suppliers_bloc.dart';
import '../../presentation/blocs/suppliers/supplier_form_bloc.dart';
import '../../presentation/blocs/customers/customers_bloc.dart';
import '../../presentation/blocs/customers/customer_form_bloc.dart';
import '../../presentation/blocs/customers/customer_search_bloc.dart';
import '../../presentation/blocs/sales/sales_bloc.dart';
import '../../presentation/blocs/sales/quick_sale/quick_sale_bloc.dart';
import '../../presentation/blocs/sales/sale_form_bloc.dart';
import '../../presentation/blocs/purchases/purchases_bloc.dart';
import '../../presentation/blocs/purchases/purchase_form_bloc.dart';
import '../../presentation/blocs/debts/debts_bloc.dart';
import '../../presentation/blocs/debts/payment_bloc.dart';
import '../../presentation/blocs/expenses/expenses_bloc.dart';
import '../../presentation/blocs/expenses/expense_form_bloc.dart';
import '../../presentation/blocs/accounting/accounting_bloc.dart';
import '../../presentation/blocs/accounting/cash_management_bloc.dart';
import '../../presentation/blocs/statistics/statistics_bloc.dart';
import '../../presentation/blocs/statistics/reports_bloc.dart';
import '../../presentation/blocs/settings/settings_bloc.dart';
import '../../presentation/blocs/settings/backup_bloc.dart';

/// حاوية الاعتمادات (DI) باستخدام GetIt
final GetIt sl = GetIt.instance;

class ServiceLocator {
  ServiceLocator._();

  /// تهيئة أولية فارغة؛ سيتم إضافة التسجيلات تدريجياً مع إنشاء الطبقات
  static Future<void> setup() async {
    // Database
    sl.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper.instance);

    // Core Services
    sl.registerLazySingleton<ApiClient>(() => ApiClient());
    sl.registerLazySingleton<ConnectivityService>(() => ConnectivityService.instance);
    sl.registerLazySingleton<NetworkService>(() => NetworkService.instance);
    sl.registerLazySingleton<SharedPreferencesService>(() => SharedPreferencesService.instance);
    sl.registerLazySingleton<SecureStorageService>(() => SecureStorageService.instance);
    sl.registerLazySingleton<CacheService>(() => CacheService.instance);
    sl.registerLazySingleton<BackupService>(() => BackupService());
    sl.registerLazySingleton<FirestoreService>(() => FirestoreService.instance);
    sl.registerLazySingleton<FirebaseService>(() => FirebaseService.instance);
    sl.registerLazySingleton<ExportService>(() => ExportService());
    sl.registerLazySingleton<NotificationService>(() => NotificationService());
    sl.registerLazySingleton<FirebaseAuthService>(() => FirebaseAuthService.instance);
    sl.registerLazySingleton<FirebaseStorageService>(() => FirebaseStorageService());
    sl.registerLazySingleton<FirebaseAnalyticsService>(() => FirebaseAnalyticsService());
    sl.registerLazySingleton<ShareService>(() => ShareService());
    sl.registerLazySingleton<PrintService>(() => PrintService());
    sl.registerLazySingleton<LoggerService>(() => LoggerService());
    sl.registerLazySingleton<SyncService>(() => SyncService.instance);
    sl.registerLazySingleton<SyncManager>(() => SyncManager());
    sl.registerLazySingleton<ConflictResolver>(() => ConflictResolver());
    sl.registerLazySingleton<SyncQueue>(() => SyncQueue());
    sl.registerLazySingleton<OfflineQueue>(() => OfflineQueue());
    await DatabaseModule.register(sl);
    await FirebaseModule.register(sl);
    await RepositoryModule.register(sl);
    await BlocModule.register(sl);

    // UseCases registrations (Suppliers)
    sl.registerLazySingleton<AddSupplier>(() => AddSupplier(sl()));
    sl.registerLazySingleton<GetSuppliers>(() => GetSuppliers(sl()));
    sl.registerLazySingleton<UpdateSupplier>(() => UpdateSupplier(sl()));
    sl.registerLazySingleton<DeleteSupplier>(() => DeleteSupplier(sl()));
    sl.registerLazySingleton<SearchSuppliers>(() => SearchSuppliers(sl()));

    // Customers
    sl.registerLazySingleton<AddCustomer>(() => AddCustomer(sl()));
    sl.registerLazySingleton<GetCustomers>(() => GetCustomers(sl()));
    sl.registerLazySingleton<UpdateCustomer>(() => UpdateCustomer(sl()));
    sl.registerLazySingleton<DeleteCustomer>(() => DeleteCustomer(sl()));
    sl.registerLazySingleton<SearchCustomers>(() => SearchCustomers(sl()));
    sl.registerLazySingleton<BlockCustomer>(() => BlockCustomer(sl()));
    sl.registerLazySingleton<GetCustomerDebts>(() => GetCustomerDebts(sl()));
    sl.registerLazySingleton<GetCustomerHistory>(() => GetCustomerHistory(sl()));

    // Purchases
    sl.registerLazySingleton<AddPurchase>(() => AddPurchase(sl()));
    sl.registerLazySingleton<GetPurchases>(() => GetPurchases(sl()));
    sl.registerLazySingleton<GetTodayPurchases>(() => GetTodayPurchases(sl()));
    sl.registerLazySingleton<GetPurchasesBySupplier>(() => GetPurchasesBySupplier(sl()));
    sl.registerLazySingleton<UpdatePurchase>(() => UpdatePurchase(sl()));
    sl.registerLazySingleton<DeletePurchase>(() => DeletePurchase(sl()));
    sl.registerLazySingleton<CancelPurchase>(() => CancelPurchase(sl()));

    // Sales
    sl.registerLazySingleton<AddSale>(() => AddSale(sl()));
    sl.registerLazySingleton<GetSales>(() => GetSales(sl()));
    sl.registerLazySingleton<GetTodaySales>(() => GetTodaySales(sl()));
    sl.registerLazySingleton<GetSalesByCustomer>(() => GetSalesByCustomer(sl()));
    sl.registerLazySingleton<UpdateSale>(() => UpdateSale(sl()));
    sl.registerLazySingleton<DeleteSale>(() => DeleteSale(sl()));
    sl.registerLazySingleton<QuickSale>(() => QuickSale(sl()));
    sl.registerLazySingleton<CancelSale>(() => CancelSale(sl()));

    // Debts
    sl.registerLazySingleton<AddDebt>(() => AddDebt(sl<DebtRepository>(), sl<CustomerRepository>()));
    sl.registerLazySingleton<GetDebts>(() => GetDebts(sl()));
    sl.registerLazySingleton<GetPendingDebts>(() => GetPendingDebts(sl()));
    sl.registerLazySingleton<GetOverdueDebts>(() => GetOverdueDebts(sl()));
    sl.registerLazySingleton<GetDebtsByPerson>(() => GetDebtsByPerson(sl()));
    sl.registerLazySingleton<UpdateDebt>(() => UpdateDebt(sl()));
    sl.registerLazySingleton<DeleteDebt>(() => DeleteDebt(sl()));
    sl.registerLazySingleton<PayDebt>(() => PayDebt(sl<DebtRepository>(), sl<DebtPaymentRepository>()));
    sl.registerLazySingleton<PartialPayment>(() => PartialPayment(sl()));
    sl.registerLazySingleton<SendReminder>(() => SendReminder(sl<NotificationService>(), sl<DebtRepository>()));

    // Expenses
    sl.registerLazySingleton<AddExpense>(() => AddExpense(sl()));
    sl.registerLazySingleton<GetDailyExpenses>(() => GetDailyExpenses(sl()));
    sl.registerLazySingleton<GetExpensesByCategory>(() => GetExpensesByCategory(sl()));
    sl.registerLazySingleton<UpdateExpense>(() => UpdateExpense(sl()));
    sl.registerLazySingleton<DeleteExpense>(() => DeleteExpense(sl()));

    // Debt payments
    sl.registerLazySingleton<AddDebtPayment>(() => AddDebtPayment(sl()));
    sl.registerLazySingleton<GetDebtPaymentsByDebt>(() => GetDebtPaymentsByDebt(sl()));
    sl.registerLazySingleton<UpdateDebtPayment>(() => UpdateDebtPayment(sl()));
    sl.registerLazySingleton<DeleteDebtPayment>(() => DeleteDebtPayment(sl()));

    // Accounting
    sl.registerLazySingleton<AddJournalEntry>(() => AddJournalEntry(sl()));
    sl.registerLazySingleton<AddJournalEntryDetail>(() => AddJournalEntryDetail(sl()));
    sl.registerLazySingleton<GetJournalEntryDetails>(() => GetJournalEntryDetails(sl()));
    sl.registerLazySingleton<GetCashBalance>(() => GetCashBalance(sl()));
    sl.registerLazySingleton<CloseDailyAccounts>(() => CloseDailyAccounts());
    sl.registerLazySingleton<GetTrialBalance>(() => GetTrialBalance());
    sl.registerLazySingleton<GenerateFinancialStatements>(() => GenerateFinancialStatements());

    // Statistics
    sl.registerLazySingleton<GetDailyStatistics>(() => GetDailyStatistics(
      statsRepo: sl<StatisticsRepository>(),
      salesRepo: sl<SalesRepository>(),
      purchaseRepo: sl<PurchaseRepository>(),
      expenseRepo: sl<ExpenseRepository>(),
    ));
    sl.registerLazySingleton<GetMonthlyStatistics>(() => GetMonthlyStatistics(sl()));
    sl.registerLazySingleton<GetWeeklyReport>(() => GetWeeklyReport(sl()));
    sl.registerLazySingleton<GetYearlyReport>(() => GetYearlyReport(sl()));
    sl.registerLazySingleton<GetProfitAnalysis>(() => GetProfitAnalysis(sl()));
    sl.registerLazySingleton<GetBestSellers>(() => GetBestSellers(sl()));
    sl.registerLazySingleton<GetCustomerRanking>(() => GetCustomerRanking(sl()));

    // Qat types
    sl.registerLazySingleton<AddQatType>(() => AddQatType(sl()));
    sl.registerLazySingleton<GetQatTypes>(() => GetQatTypes(sl()));
    sl.registerLazySingleton<GetQatTypeById>(() => GetQatTypeById(sl()));
    sl.registerLazySingleton<UpdateQatType>(() => UpdateQatType(sl()));
    sl.registerLazySingleton<DeleteQatType>(() => DeleteQatType(sl()));

    // Sync
    sl.registerLazySingleton<SyncAll>(() => SyncAll(sl()));
    sl.registerLazySingleton<CheckSyncStatus>(() => CheckSyncStatus(sl()));
    sl.registerLazySingleton<QueueOperation>(() => QueueOperation(sl()));
    sl.registerLazySingleton<SyncData>(() => SyncData(sl()));
    sl.registerLazySingleton<ResolveConflicts>(() => ResolveConflicts(sl()));
    sl.registerLazySingleton<QueueOfflineOperation>(() => QueueOfflineOperation(sl()));

    // Backup
    sl.registerLazySingleton<CreateBackup>(() => CreateBackup(
      sl<BackupRepository>(),
      sl<SalesRepository>(),
      sl<PurchaseRepository>(),
      sl<CustomerRepository>(),
      sl<SupplierRepository>(),
      sl<DebtRepository>(),
      sl<ExpenseRepository>(),
    ));
    sl.registerLazySingleton<RestoreBackup>(() => RestoreBackup(sl()));
    sl.registerLazySingleton<ExportToExcel>(() => ExportToExcel(sl()));
    sl.registerLazySingleton<ScheduleAutoBackup>(() => ScheduleAutoBackup(sl()));
    
    // Reports
    sl.registerLazySingleton<PrintReport>(() => PrintReport(
      statsRepo: sl<StatisticsRepository>(),
      printService: sl<PrintService>(),
      exportService: sl<ExportService>(),
    ));
    sl.registerLazySingleton<ShareReport>(() => ShareReport(
      statsRepo: sl<StatisticsRepository>(),
      shareService: sl<ShareService>(),
      exportService: sl<ExportService>(),
    ));

    // Blocs (factories)
    sl.registerFactory<AppBloc>(() => AppBloc());
    sl.registerFactory<SplashBloc>(() => SplashBloc());
    sl.registerFactory<HomeBloc>(() => HomeBloc(
      prefs: sl<SharedPreferencesService>(),
      logger: sl<LoggerService>(),
    ));
    sl.registerFactory<AppSettingsBloc>(() => AppSettingsBloc());
    sl.registerFactory<AuthBloc>(() => AuthBloc());
    sl.registerFactory<SyncBloc>(() => SyncBloc(
      syncManager: sl<SyncManager>(),
      syncAll: sl<SyncAll>(),
      checkSyncStatus: sl<CheckSyncStatus>(),
      queueOfflineOperation: sl<QueueOfflineOperation>(),
      resolveConflicts: sl<ResolveConflicts>(),
      connectivityService: sl<ConnectivityService>(),
    ));
    sl.registerFactory<DashboardBloc>(() => DashboardBloc(
      getDailyStatistics: sl<GetDailyStatistics>(),
      getMonthlyStatistics: sl<GetMonthlyStatistics>(),
      getTodaySales: sl<GetTodaySales>(),
      getTodayPurchases: sl<GetTodayPurchases>(),
      getPendingDebts: sl<GetPendingDebts>(),
      getOverdueDebts: sl<GetOverdueDebts>(),
    ));
    sl.registerFactory<SuppliersBloc>(() => SuppliersBloc(
      getSuppliers: sl(),
      addSupplier: sl(),
      updateSupplier: sl(),
      deleteSupplier: sl(),
      searchSuppliersUseCase: sl(),
    ));
    sl.registerFactory<SupplierFormBloc>(() => SupplierFormBloc());
    sl.registerFactory<CustomersBloc>(() => CustomersBloc(
      getCustomers: sl(),
      addCustomer: sl(),
      updateCustomer: sl(),
      deleteCustomer: sl(),
      blockCustomer: sl(),
      searchCustomersUseCase: sl(),
    ));
    sl.registerFactory<CustomerFormBloc>(() => CustomerFormBloc(
      addCustomer: sl(),
      updateCustomer: sl(),
      getCustomers: sl(),
    ));
    sl.registerFactory<CustomerSearchBloc>(() => CustomerSearchBloc());
    sl.registerFactory<SalesBloc>(() => SalesBloc(
      getSales: sl(),
      getTodaySales: sl(),
      getSalesByCustomer: sl(),
      addSale: sl(),
      updateSale: sl(),
      deleteSale: sl(),
      cancelSale: sl(),
    ));
    sl.registerFactory<QuickSaleBloc>(() => QuickSaleBloc(
      quickSaleUseCase: sl(),
    ));
    sl.registerFactory<SaleFormBloc>(() => SaleFormBloc());
    sl.registerFactory<PurchasesBloc>(() => PurchasesBloc(
      getPurchases: sl(),
      getTodayPurchases: sl(),
      getPurchasesBySupplier: sl(),
      addPurchase: sl(),
      updatePurchase: sl(),
      deletePurchase: sl(),
      cancelPurchase: sl(),
    ));
    sl.registerFactory<PurchaseFormBloc>(() => PurchaseFormBloc());
    sl.registerFactory<DebtsBloc>(() => DebtsBloc(
      getDebts: sl(),
      getPendingDebts: sl(),
      getOverdueDebts: sl(),
      getDebtsByPerson: sl(),
      addDebt: sl(),
      updateDebt: sl(),
      deleteDebt: sl(),
      partialPayment: sl(),
    ));
    sl.registerFactory<PaymentBloc>(() => PaymentBloc(
      addDebtPayment: sl<AddDebtPayment>(),
      updateDebtPayment: sl<UpdateDebtPayment>(),
      deleteDebtPayment: sl<DeleteDebtPayment>(),
      getDebtPaymentsByDebt: sl<GetDebtPaymentsByDebt>(),
    ));
    sl.registerFactory<ExpensesBloc>(() => ExpensesBloc(
      repository: sl<ExpenseRepository>(),
      getTodayExpenses: sl<GetDailyExpenses>(),
      getExpensesByType: sl<GetExpensesByCategory>(),
      addExpense: sl<AddExpense>(),
      updateExpense: sl<UpdateExpense>(),
      deleteExpense: sl<DeleteExpense>(),
    ));
    sl.registerFactory<ExpenseFormBloc>(() => ExpenseFormBloc());
    sl.registerFactory<AccountingBloc>(() => AccountingBloc(
      salesRepository: sl<SalesRepository>(),
      purchaseRepository: sl<PurchaseRepository>(),
      expenseRepository: sl<ExpenseRepository>(),
    ));
    sl.registerFactory<CashManagementBloc>(() => CashManagementBloc(
      getDailyStats: sl<GetDailyStatistics>(),
      logger: sl<LoggerService>(),
    ));
    sl.registerFactory<StatisticsBloc>(() => StatisticsBloc(
      getDailyStats: sl<GetDailyStatistics>(),
      repository: sl<StatisticsRepository>(),
      getMonthStats: sl<GetMonthlyStatistics>(),
      getYearStats: sl<GetYearlyReport>(),
    ));
    sl.registerFactory<ReportsBloc>(() => ReportsBloc(
      printReport: sl<PrintReport>(),
      shareReport: sl<ShareReport>(),
      getDailyStats: sl<GetDailyStatistics>(),
      getMonthlyStats: sl<GetMonthlyStatistics>(),
      logger: sl<LoggerService>(),
    ));
    sl.registerFactory<SettingsBloc>(() => SettingsBloc(
      prefs: sl<SharedPreferencesService>(),
      logger: sl<LoggerService>(),
    ));
    sl.registerFactory<BackupBloc>(() => BackupBloc(
      createBackup: sl<CreateBackup>(),
      restoreBackup: sl<RestoreBackup>(),
      exportToExcel: sl<ExportToExcel>(),
      scheduleAutoBackup: sl<ScheduleAutoBackup>(),
      logger: sl<LoggerService>(),
    ));
  }
}
