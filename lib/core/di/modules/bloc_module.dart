// ignore_for_file: public_member_api_docs

import 'package:get_it/get_it.dart';

import '../../../domain/repositories/expense_repository.dart';
import '../../../domain/repositories/purchase_repository.dart';
import '../../../domain/repositories/sales_repository.dart';
import '../../../domain/repositories/statistics_repository.dart';
import '../../../domain/usecases/backup/create_backup.dart';
import '../../../domain/usecases/backup/export_to_excel.dart';
import '../../../domain/usecases/backup/restore_backup.dart';
import '../../../domain/usecases/backup/schedule_auto_backup.dart';
import '../../../domain/usecases/debt_payments/add_debt_payment.dart';
import '../../../domain/usecases/debt_payments/delete_debt_payment.dart';
import '../../../domain/usecases/debt_payments/get_debt_payments_by_debt.dart';
import '../../../domain/usecases/debt_payments/update_debt_payment.dart';
import '../../../domain/usecases/debts/get_overdue_debts.dart';
import '../../../domain/usecases/debts/get_pending_debts.dart';
import '../../../domain/usecases/expenses/add_expense.dart';
import '../../../domain/usecases/expenses/delete_expense.dart';
import '../../../domain/usecases/expenses/get_daily_expenses.dart';
import '../../../domain/usecases/expenses/get_expenses_by_category.dart';
import '../../../domain/usecases/expenses/update_expense.dart';
import '../../../domain/usecases/purchases/get_today_purchases.dart';
import '../../../domain/usecases/reports/print_report.dart';
import '../../../domain/usecases/reports/share_report.dart';
import '../../../domain/usecases/sales/get_today_sales.dart';
import '../../../domain/usecases/statistics/get_daily_statistics.dart';
import '../../../domain/usecases/statistics/get_monthly_statistics.dart';
import '../../../domain/usecases/statistics/get_weekly_report.dart';
import '../../../domain/usecases/statistics/get_yearly_report.dart';
import '../../../domain/usecases/sync/check_sync_status.dart';
import '../../../domain/usecases/sync/queue_offline_operation.dart';
import '../../../domain/usecases/sync/resolve_conflicts.dart';
import '../../../domain/usecases/sync/sync_all.dart';
import '../../../domain/usecases/inventory/get_inventory_list.dart';
import '../../../domain/usecases/inventory/update_inventory_item.dart';
import '../../../domain/usecases/inventory/adjust_inventory_quantity.dart';
import '../../../domain/usecases/inventory/get_inventory_transactions.dart';
import '../../../domain/usecases/inventory/get_inventory_statistics.dart';
import '../../../domain/usecases/returns/add_return.dart';
import '../../../domain/usecases/returns/get_returns_list.dart';
import '../../../domain/usecases/returns/confirm_return.dart';
import '../../../domain/usecases/returns/get_returns_statistics.dart';
import '../../../domain/usecases/damaged_items/add_damaged_item.dart';
import '../../../domain/usecases/damaged_items/get_damaged_items_list.dart';
import '../../../domain/usecases/damaged_items/get_damage_statistics.dart';
import '../../../presentation/blocs/accounting/accounting_bloc.dart';
import '../../../presentation/blocs/accounting/cash_management_bloc.dart';
import '../../../presentation/blocs/app/app_bloc.dart';
import '../../../presentation/blocs/app/app_settings_bloc.dart';
import '../../../presentation/blocs/auth/auth_bloc.dart';
import '../../../presentation/blocs/customers/customer_form_bloc.dart';
import '../../../presentation/blocs/customers/customer_search_bloc.dart';
import '../../../presentation/blocs/customers/customers_bloc.dart';
import '../../../presentation/blocs/debts/debts_bloc.dart';
import '../../../presentation/blocs/debts/payment_bloc.dart';
import '../../../presentation/blocs/expenses/expense_form_bloc.dart';
import '../../../presentation/blocs/expenses/expenses_bloc.dart';
import '../../../presentation/blocs/home/dashboard_bloc.dart';
import '../../../presentation/blocs/home/home_bloc.dart';
import '../../../presentation/blocs/purchases/purchase_form_bloc.dart';
import '../../../presentation/blocs/purchases/purchases_bloc.dart';
import '../../../presentation/blocs/sales/quick_sale/quick_sale_bloc.dart';
import '../../../presentation/blocs/sales/sale_form_bloc.dart';
import '../../../presentation/blocs/sales/sales_bloc.dart';
import '../../../presentation/blocs/settings/backup_bloc.dart';
import '../../../presentation/blocs/settings/settings_bloc.dart';
import '../../../presentation/blocs/splash/splash_bloc.dart';
import '../../../presentation/blocs/statistics/reports_bloc.dart';
import '../../../presentation/blocs/statistics/statistics_bloc.dart';
import '../../../presentation/blocs/suppliers/supplier_form_bloc.dart';
import '../../../presentation/blocs/suppliers/suppliers_bloc.dart';
import '../../../presentation/blocs/qat_types/qat_types_bloc.dart';
import '../../../presentation/blocs/sync/sync_bloc.dart';
import '../../../presentation/blocs/inventory/inventory_bloc.dart';
import '../../services/local/shared_preferences_service.dart';
import '../../services/logger_service.dart';
import '../../services/network/connectivity_service.dart';
import '../../services/sync/sync_manager.dart';
import '../../services/backup_service.dart';

class BlocModule {
  static Future<void> register(GetIt sl) async {
    sl.registerFactory<AppBloc>(() => AppBloc(
      prefsService: sl<SharedPreferencesService>(),
      syncManager: sl<SyncManager>(),
      backupService: sl<BackupService>(),
      logger: sl<LoggerService>(),
    ));
    
    sl.registerFactory<SplashBloc>(SplashBloc.new);
    
    sl.registerFactory<HomeBloc>(() => HomeBloc(
      prefs: sl<SharedPreferencesService>(),
      logger: sl<LoggerService>(),
    ));
    
    sl.registerFactory<AppSettingsBloc>(AppSettingsBloc.new);
    
    sl.registerFactory<AuthBloc>(AuthBloc.new);
    
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
    
    sl.registerFactory<SupplierFormBloc>(SupplierFormBloc.new);
    
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
    
    sl.registerFactory<CustomerSearchBloc>(CustomerSearchBloc.new);
    
    sl.registerFactory<QatTypesBloc>(() => QatTypesBloc(
      getQatTypes: sl(),
      getQatTypeById: sl(),
      addQatType: sl(),
      updateQatType: sl(),
      deleteQatType: sl(),
    ));
    
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
    
    sl.registerFactory<SaleFormBloc>(SaleFormBloc.new);
    
    sl.registerFactory<PurchasesBloc>(() => PurchasesBloc(
      getPurchases: sl(),
      getTodayPurchases: sl(),
      getPurchasesBySupplier: sl(),
      addPurchase: sl(),
      updatePurchase: sl(),
      deletePurchase: sl(),
      cancelPurchase: sl(),
    ));
    
    sl.registerFactory<PurchaseFormBloc>(PurchaseFormBloc.new);
    
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
    
    sl.registerFactory<ExpenseFormBloc>(ExpenseFormBloc.new);
    
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
      getWeeklyReport: sl<GetWeeklyReport>(),
      getYearlyReport: sl<GetYearlyReport>(),
      logger: sl<LoggerService>(),
    ));
    
    sl.registerFactory<SettingsBloc>(() => SettingsBloc(
      prefs: sl<SharedPreferencesService>(),
      logger: sl<LoggerService>(),
      syncManager: sl<SyncManager>(),
      backupService: sl<BackupService>(),
    ));
    
    sl.registerFactory<BackupBloc>(() => BackupBloc(
      createBackup: sl<CreateBackup>(),
      restoreBackup: sl<RestoreBackup>(),
      exportToExcel: sl<ExportToExcel>(),
      scheduleAutoBackup: sl<ScheduleAutoBackup>(),
      logger: sl<LoggerService>(),
    ));
    
    sl.registerFactory<InventoryBloc>(() => InventoryBloc(
      getInventoryList: sl<GetInventoryList>(),
      getInventoryTransactions: sl<GetInventoryTransactions>(),
      getInventoryStatistics: sl<GetInventoryStatistics>(),
      updateInventoryItem: sl<UpdateInventoryItem>(),
      adjustInventoryQuantity: sl<AdjustInventoryQuantity>(),
      addReturn: sl<AddReturn>(),
      getReturnsList: sl<GetReturnsList>(),
      confirmReturn: sl<ConfirmReturn>(),
      getReturnsStatistics: sl<GetReturnsStatistics>(),
      addDamagedItem: sl<AddDamagedItem>(),
      getDamagedItemsList: sl<GetDamagedItemsList>(),
      getDamageStatistics: sl<GetDamageStatistics>(),
    ));
  }
}
