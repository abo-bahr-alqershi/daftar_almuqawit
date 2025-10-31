// ignore_for_file: public_member_api_docs

import '../../../core/constants/firebase_constants.dart';
import '../../../core/services/firebase/firestore_service.dart';
import '../../models/sale_model.dart';
import 'base_remote_datasource.dart';

class SalesRemoteDataSource extends BaseRemoteDataSource {
  SalesRemoteDataSource(FirestoreService super.fs);

  Future<void> upsert(SaleModel model) async {
    await col(FirebaseConstants.sales).doc('${model.id}').set(model.toMap());
  }

  Future<void> delete(int id) async {
    await col(FirebaseConstants.sales).doc('$id').delete();
  }

  Future<List<SaleModel>> fetchAll() async {
    final snap = await col(FirebaseConstants.sales).get();
    return snap.docs.map((d) => SaleModel.fromMap(d.data())).toList();
  }
}
