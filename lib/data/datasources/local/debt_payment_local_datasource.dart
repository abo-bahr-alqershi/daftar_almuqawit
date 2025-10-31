// ignore_for_file: public_member_api_docs

import '../../database/tables/debt_payments_table.dart';
import '../../models/debt_payment_model.dart';
import 'base_local_datasource.dart';

class DebtPaymentLocalDataSource extends BaseLocalDataSource {
  DebtPaymentLocalDataSource(super.dbHelper);

  Future<int> insert(DebtPaymentModel model) async {
    final database = await db;
    return database.insert(DebtPaymentsTable.table, model.toMap());
  }

  Future<List<DebtPaymentModel>> getByDebt(int debtId) async {
    final database = await db;
    final rows = await database.query(
      DebtPaymentsTable.table,
      where: '${DebtPaymentsTable.cDebtId} = ?',
      whereArgs: [debtId],
      orderBy: '${DebtPaymentsTable.cPaymentDate} DESC, ${DebtPaymentsTable.cPaymentTime} DESC',
    );
    return rows.map((e) => DebtPaymentModel.fromMap(e)).toList();
  }
}
