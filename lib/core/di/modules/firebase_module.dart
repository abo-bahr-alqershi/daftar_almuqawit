// ignore_for_file: public_member_api_docs

import 'package:get_it/get_it.dart';

import '../../../data/datasources/remote/suppliers_remote_datasource.dart';
import '../../../data/datasources/remote/customers_remote_datasource.dart';
import '../../../data/datasources/remote/qat_types_remote_datasource.dart';
import '../../../data/datasources/remote/purchases_remote_datasource.dart';
import '../../../data/datasources/remote/sales_remote_datasource.dart';
import '../../../data/datasources/remote/debts_remote_datasource.dart';
import '../../../data/datasources/remote/debt_payments_remote_datasource.dart';
import '../../../data/datasources/remote/expenses_remote_datasource.dart';
import '../../../data/datasources/remote/accounts_remote_datasource.dart';
import '../../../data/datasources/remote/journal_entries_remote_datasource.dart';
import '../../../data/datasources/remote/journal_entry_details_remote_datasource.dart';
import '../../../data/datasources/remote/daily_stats_remote_datasource.dart';
import '../../../data/datasources/remote/backup_remote_datasource.dart';
import '../../../data/datasources/remote/sync_remote_datasource.dart';

class FirebaseModule {
  static Future<void> register(GetIt sl) async {
    // Firebase is already initialized in main.dart
    // FirestoreService will be accessed via lazy singleton when needed

    sl.registerLazySingleton<SuppliersRemoteDataSource>(
      () => SuppliersRemoteDataSource(sl()),
    );
    sl.registerLazySingleton<CustomersRemoteDataSource>(
      () => CustomersRemoteDataSource(sl()),
    );
    sl.registerLazySingleton<QatTypesRemoteDataSource>(
      () => QatTypesRemoteDataSource(sl()),
    );
    sl.registerLazySingleton<PurchasesRemoteDataSource>(
      () => PurchasesRemoteDataSource(sl()),
    );
    sl.registerLazySingleton<SalesRemoteDataSource>(
      () => SalesRemoteDataSource(sl()),
    );
    sl.registerLazySingleton<DebtsRemoteDataSource>(
      () => DebtsRemoteDataSource(sl()),
    );
    sl.registerLazySingleton<DebtPaymentsRemoteDataSource>(
      () => DebtPaymentsRemoteDataSource(sl()),
    );
    sl.registerLazySingleton<ExpensesRemoteDataSource>(
      () => ExpensesRemoteDataSource(sl()),
    );
    sl.registerLazySingleton<AccountsRemoteDataSource>(
      () => AccountsRemoteDataSource(sl()),
    );
    sl.registerLazySingleton<JournalEntriesRemoteDataSource>(
      () => JournalEntriesRemoteDataSource(sl()),
    );
    sl.registerLazySingleton<JournalEntryDetailsRemoteDataSource>(
      () => JournalEntryDetailsRemoteDataSource(sl()),
    );
    sl.registerLazySingleton<DailyStatsRemoteDataSource>(
      () => DailyStatsRemoteDataSource(sl()),
    );
    sl.registerLazySingleton<BackupRemoteDataSource>(
      () => BackupRemoteDataSource(sl()),
    );
    sl.registerLazySingleton<SyncRemoteDataSource>(
      () => SyncRemoteDataSource(sl()),
    );
  }
}
