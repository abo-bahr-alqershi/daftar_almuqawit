// ignore_for_file: public_member_api_docs

import '../../models/statistics_model.dart';
import 'base_local_datasource.dart';

class StatisticsLocalDataSource extends BaseLocalDataSource<DailyStatisticsModel> {
  StatisticsLocalDataSource(super.dbHelper);

  @override
  String get tableName => 'daily_stats';

  @override
  DailyStatisticsModel fromMap(Map<String, dynamic> map) => DailyStatisticsModel.fromMap(map);

  Future<DailyStatisticsModel?> getDaily(String date) async {
    final database = await db;
    final rows = await database.query('daily_stats', where: 'date = ?', whereArgs: [date], limit: 1);
    if (rows.isEmpty) return null;
    return DailyStatisticsModel.fromMap(rows.first);
  }

  Future<List<DailyStatisticsModel>> getMonthly(int year, int month) async {
    final database = await db;
    final prefix = '$year-${month.toString().padLeft(2, '0')}-';
    final rows = await database.query('daily_stats', where: 'date LIKE ?', whereArgs: ['$prefix%'], orderBy: 'date ASC');
    return rows.map((e) => DailyStatisticsModel.fromMap(e)).toList();
  }
}
