// ignore_for_file: public_member_api_docs

import '../../database/tables/qat_types_table.dart';
import '../../models/qat_type_model.dart';
import 'base_local_datasource.dart';

class QatTypeLocalDataSource extends BaseLocalDataSource {
  QatTypeLocalDataSource(super.dbHelper);

  Future<int> insert(QatTypeModel model) async {
    final database = await db;
    return database.insert(QatTypesTable.table, model.toMap());
  }

  Future<void> update(QatTypeModel model) async {
    final database = await db;
    await database.update(
      QatTypesTable.table,
      model.toMap(),
      where: '${QatTypesTable.cId} = ?',
      whereArgs: [model.id],
    );
  }

  Future<void> delete(int id) async {
    final database = await db;
    await database.delete(
      QatTypesTable.table,
      where: '${QatTypesTable.cId} = ?',
      whereArgs: [id],
    );
  }

  Future<QatTypeModel?> getById(int id) async {
    final database = await db;
    final rows = await database.query(
      QatTypesTable.table,
      where: '${QatTypesTable.cId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return QatTypeModel.fromMap(rows.first);
  }

  Future<List<QatTypeModel>> getAll() async {
    final database = await db;
    final rows = await database.query(QatTypesTable.table, orderBy: QatTypesTable.cName);
    return rows.map((e) => QatTypeModel.fromMap(e)).toList();
  }
}
