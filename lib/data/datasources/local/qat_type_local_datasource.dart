// ignore_for_file: public_member_api_docs

import '../../database/tables/qat_types_table.dart';
import '../../models/qat_type_model.dart';
import 'base_local_datasource.dart';

class QatTypeLocalDataSource extends BaseLocalDataSource<QatTypeModel> {
  QatTypeLocalDataSource(super.dbHelper);

  @override
  String get tableName => QatTypesTable.table;

  @override
  QatTypeModel fromMap(Map<String, dynamic> map) => QatTypeModel.fromMap(map);

  /// البحث في أنواع القات بالاسم
  Future<List<QatTypeModel>> searchByName(String query) async {
    return await search(
      column: QatTypesTable.cName,
      query: query,
      orderBy: '${QatTypesTable.cName} COLLATE NOCASE',
    );
  }
}
