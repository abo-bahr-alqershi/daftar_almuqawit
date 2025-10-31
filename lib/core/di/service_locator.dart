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
import '../../data/datasources/local/supplier_local_datasource.dart';
import '../../data/datasources/local/customer_local_datasource.dart';
import '../../data/datasources/local/qat_type_local_datasource.dart';
import '../../data/datasources/local/purchase_local_datasource.dart';
import '../../data/datasources/local/sales_local_datasource.dart';
import '../../data/datasources/local/debt_local_datasource.dart';
import '../../data/datasources/local/debt_payment_local_datasource.dart';
import '../../data/datasources/local/expense_local_datasource.dart';
import '../../data/datasources/local/accounting_local_datasource.dart';
import '../../data/datasources/local/statistics_local_datasource.dart';
import '../../data/datasources/local/sync_local_datasource.dart';

// Remote DataSources
import '../../data/datasources/remote/suppliers_remote_datasource.dart';
import '../../data/datasources/remote/customers_remote_datasource.dart';
import '../../data/datasources/remote/qat_types_remote_datasource.dart';
import '../../data/datasources/remote/purchases_remote_datasource.dart';
import '../../data/datasources/remote/sales_remote_datasource.dart';
import '../../data/datasources/remote/debts_remote_datasource.dart';
import '../../data/datasources/remote/debt_payments_remote_datasource.dart';
import '../../data/datasources/remote/expenses_remote_datasource.dart';
import '../../data/datasources/remote/accounts_remote_datasource.dart';
import '../../data/datasources/remote/journal_entries_remote_datasource.dart';
import '../../data/datasources/remote/journal_entry_details_remote_datasource.dart';
import '../../data/datasources/remote/daily_stats_remote_datasource.dart';

// Repositories impl
import '../../data/repositories/supplier_repository_impl.dart';
import '../../data/repositories/customer_repository_impl.dart';
import '../../data/repositories/qat_type_repository_impl.dart';
import '../../data/repositories/purchase_repository_impl.dart';
import '../../data/repositories/sale_repository_impl.dart';
import '../../data/repositories/debt_repository_impl.dart';
import '../../data/repositories/debt_payment_repository_impl.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../data/repositories/accounting_repository_impl.dart';
import '../../data/repositories/statistics_repository_impl.dart';
import '../../data/repositories/sync_repository_impl.dart';
import '../../data/repositories/backup_repository_impl.dart';

// Repositories interfaces
import '../../domain/repositories/supplier_repository.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../domain/repositories/qat_type_repository.dart';
import '../../domain/repositories/purchase_repository.dart';
import '../../domain/repositories/sales_repository.dart';
import '../../domain/repositories/debt_repository.dart';
import '../../domain/repositories/debt_payment_repository.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/repositories/accounting_repository.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../../domain/repositories/sync_repository.dart';
import '../../domain/repositories/backup_repository.dart';

// UseCases
import '../../domain/usecases/base/base_usecase.dart';
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
import '../../domain/usecases/backup/restore_backup.dart';
import '../../domain/usecases/backup/export_to_excel.dart';
import '../../domain/usecases/backup/schedule_auto_backup.dart';

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
    sl.registerLazySingleton<ConnectivityService>(() => ConnectivityService());
    sl.registerLazySingleton<NetworkService>(() => NetworkService(sl<ConnectivityService>(), sl<ApiClient>()));
    sl.registerLazySingleton<SharedPreferencesService>(() => SharedPreferencesService());
    sl.registerLazySingleton<SecureStorageService>(() => SecureStorageService());
    sl.registerLazySingleton<BackupService>(() => BackupService());
    sl.registerLazySingleton<FirestoreService>(() => const FirestoreService());
    sl.registerLazySingleton<FirebaseService>(() => FirebaseService());
    sl.registerLazySingleton<ExportService>(() => ExportService());
    sl.registerLazySingleton<NotificationService>(() => NotificationService());
    sl.registerLazySingleton<FirebaseAuthService>(() => FirebaseAuthService());
    sl.registerLazySingleton<FirebaseStorageService>(() => FirebaseStorageService());
    sl.registerLazySingleton<FirebaseAnalyticsService>(() => FirebaseAnalyticsService());
    sl.registerLazySingleton<ShareService>(() => ShareService());
    sl.registerLazySingleton<PrintService>(() => PrintService());
    sl.registerLazySingleton<LoggerService>(() => LoggerService());
    sl.registerLazySingleton<SyncService>(() => SyncService());
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
    sl.registerLazySingleton<AddDebt>(() => AddDebt(sl()));
    sl.registerLazySingleton<GetDebts>(() => GetDebts(sl()));
    sl.registerLazySingleton<GetPendingDebts>(() => GetPendingDebts(sl()));
    sl.registerLazySingleton<GetOverdueDebts>(() => GetOverdueDebts(sl()));
    sl.registerLazySingleton<GetDebtsByPerson>(() => GetDebtsByPerson(sl()));
    sl.registerLazySingleton<UpdateDebt>(() => UpdateDebt(sl()));
    sl.registerLazySingleton<DeleteDebt>(() => DeleteDebt(sl()));
    sl.registerLazySingleton<PayDebt>(() => PayDebt(sl()));
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

    // Accounting
    sl.registerLazySingleton<AddJournalEntry>(() => AddJournalEntry(sl()));
    sl.registerLazySingleton<AddJournalEntryDetail>(() => AddJournalEntryDetail(sl()));
    sl.registerLazySingleton<GetJournalEntryDetails>(() => GetJournalEntryDetails(sl()));
    sl.registerLazySingleton<GetCashBalance>(() => GetCashBalance(sl()));
    sl.registerLazySingleton<CloseDailyAccounts>(() => CloseDailyAccounts());
    sl.registerLazySingleton<GetTrialBalance>(() => GetTrialBalance());
    sl.registerLazySingleton<GenerateFinancialStatements>(() => GenerateFinancialStatements());

    // Statistics
    sl.registerLazySingleton<GetDailyStatistics>(() => GetDailyStatistics(sl()));
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
    sl.registerLazySingleton<CreateBackup>(() => CreateBackup(sl()));
    sl.registerLazySingleton<RestoreBackup>(() => RestoreBackup(sl()));
    sl.registerLazySingleton<ExportToExcel>(() => ExportToExcel(sl()));
    sl.registerLazySingleton<ScheduleAutoBackup>(() => ScheduleAutoBackup(sl()));

    // Blocs (factories)
    sl.registerFactory<AppBloc>(() => AppBloc());
    sl.registerFactory<SplashBloc>(() => SplashBloc());
    sl.registerFactory<HomeBloc>(() => HomeBloc());
    sl.registerFactory<AppSettingsBloc>(() => AppSettingsBloc());
    sl.registerFactory<AuthBloc>(() => AuthBloc());
    sl.registerFactory<SyncBloc>(() => SyncBloc());
    sl.registerFactory<DashboardBloc>(() => DashboardBloc());
    sl.registerFactory<SuppliersBloc>(() => SuppliersBloc());
    sl.registerFactory<SupplierFormBloc>(() => SupplierFormBloc());
    sl.registerFactory<CustomersBloc>(() => CustomersBloc());
    sl.registerFactory<CustomerFormBloc>(() => CustomerFormBloc());
    sl.registerFactory<CustomerSearchBloc>(() => CustomerSearchBloc());
    sl.registerFactory<SalesBloc>(() => SalesBloc());
    sl.registerFactory<QuickSaleBloc>(() => QuickSaleBloc());
    sl.registerFactory<SaleFormBloc>(() => SaleFormBloc());
    sl.registerFactory<PurchasesBloc>(() => PurchasesBloc());
    sl.registerFactory<PurchaseFormBloc>(() => PurchaseFormBloc());
    sl.registerFactory<DebtsBloc>(() => DebtsBloc());
    sl.registerFactory<PaymentBloc>(() => PaymentBloc());
    sl.registerFactory<ExpensesBloc>(() => ExpensesBloc());
    sl.registerFactory<ExpenseFormBloc>(() => ExpenseFormBloc());
    sl.registerFactory<AccountingBloc>(() => AccountingBloc());
    sl.registerFactory<CashManagementBloc>(() => CashManagementBloc());
    sl.registerFactory<StatisticsBloc>(() => StatisticsBloc());
    sl.registerFactory<ReportsBloc>(() => ReportsBloc());
    sl.registerFactory<SettingsBloc>(() => SettingsBloc());
    sl.registerFactory<BackupBloc>(() => BackupBloc());
  }
}
