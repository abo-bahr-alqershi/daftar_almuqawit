// ignore_for_file: public_member_api_docs

import '../../../core/constants/firebase_constants.dart';
import '../../../core/services/firebase/firestore_service.dart';
import '../../models/qat_type_model.dart';
import 'base_remote_datasource.dart';

class QatTypesRemoteDataSource extends BaseRemoteDataSource {
  QatTypesRemoteDataSource(FirestoreService super.fs);

  Future<void> upsert(QatTypeModel model) async {
    await col(FirebaseConstants.qatTypes).doc('${model.id}').set(model.toMap());
  }

  Future<void> delete(int id) async {
    await col(FirebaseConstants.qatTypes).doc('$id').delete();
  }

  Future<List<QatTypeModel>> fetchAll() async {
    final snap = await col(FirebaseConstants.qatTypes).get();
    return snap.docs.map((d) => QatTypeModel.fromMap(d.data())).toList();
  }
}
