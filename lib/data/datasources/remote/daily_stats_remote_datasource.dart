// ignore_for_file: public_member_api_docs

import '../../../core/constants/firebase_constants.dart';
import '../../../core/services/firebase/firestore_service.dart';
import '../../models/statistics_model.dart';
import 'base_remote_datasource.dart';

class DailyStatsRemoteDataSource extends BaseRemoteDataSource {
  DailyStatsRemoteDataSource(FirestoreService fs) : super(fs);

  Future<void> upsert(DailyStatisticsModel model) async {
    await col(FirebaseConstants.dailyStats).doc('${model.date}').set(model.toMap());
  }

  Future<DailyStatisticsModel?> fetchByDate(String date) async {
    final doc = await col(FirebaseConstants.dailyStats).doc(date).get();
    if (!doc.exists) return null;
    return DailyStatisticsModel.fromMap(doc.data()!);
  }
}
