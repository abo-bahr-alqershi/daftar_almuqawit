// ignore_for_file: public_member_api_docs

import '../../../core/constants/firebase_constants.dart';
import '../../../core/services/firebase/firestore_service.dart';
import '../../models/purchase_model.dart';
import 'base_remote_datasource.dart';

class PurchasesRemoteDataSource extends BaseRemoteDataSource {
  PurchasesRemoteDataSource(FirestoreService super.fs);

  Future<void> upsert(PurchaseModel model) async {
    await col(FirebaseConstants.purchases).doc('${model.id}').set(model.toMap());
  }

  Future<void> delete(int id) async {
    await col(FirebaseConstants.purchases).doc('$id').delete();
  }

  Future<List<PurchaseModel>> fetchAll() async {
    final snap = await col(FirebaseConstants.purchases).get();
    return snap.docs.map((d) => PurchaseModel.fromMap(d.data())).toList();
  }
}
