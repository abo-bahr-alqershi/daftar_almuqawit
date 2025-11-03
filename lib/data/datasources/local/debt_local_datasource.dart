// ignore_for_file: public_member_api_docs

import '../../database/tables/debts_table.dart';
import '../../models/debt_model.dart';
import 'base_local_datasource.dart';

class DebtLocalDataSource extends BaseLocalDataSource<DebtModel> {
  DebtLocalDataSource(super.dbHelper);

  @override
  String get tableName => DebtsTable.table;

  @override
  DebtModel fromMap(Map<String, dynamic> map) => DebtModel.fromMap(map);

  /// جلب الديون حسب الشخص (عميل أو مورد)
  Future<List<DebtModel>> getByPerson(String personType, int personId) async {
    return await getWhere(
      where: '${DebtsTable.cPersonType} = ? AND ${DebtsTable.cPersonId} = ?',
      whereArgs: [personType, personId],
      orderBy: '${DebtsTable.cDate} DESC',
    );
  }

  /// جلب الديون غير المدفوعة
  Future<List<DebtModel>> getUnpaid() async {
    return await getWhere(
      where: '${DebtsTable.cRemainingAmount} > 0',
      whereArgs: [],
      orderBy: '${DebtsTable.cDate} ASC',
    );
  }

  /// جلب الديون حسب الحالة
  Future<List<DebtModel>> getByStatus(String status) async {
    return await getWhere(
      where: '${DebtsTable.cStatus} = ?',
      whereArgs: [status],
      orderBy: '${DebtsTable.cDate} DESC',
    );
  }

  /// جلب الديون المعلقة (غير المسددة)
  Future<List<DebtModel>> getPending() async {
    return await getWhere(
      where: "${DebtsTable.cStatus} != ?",
      whereArgs: ['مسدد'],
      orderBy: '${DebtsTable.cDate} DESC',
    );
  }

  /// جلب الديون المتأخرة
  Future<List<DebtModel>> getOverdue(String today) async {
    return await getWhere(
      where: "${DebtsTable.cDueDate} IS NOT NULL AND ${DebtsTable.cDueDate} < ? AND ${DebtsTable.cStatus} != ?",
      whereArgs: [today, 'مسدد'],
      orderBy: '${DebtsTable.cDueDate} ASC',
    );
  }
}
