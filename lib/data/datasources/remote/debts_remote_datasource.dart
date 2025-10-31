// ignore_for_file: public_member_api_docs

import '../../../core/constants/firebase_constants.dart';
import '../../../core/services/firebase/firestore_service.dart';
import '../../models/debt_model.dart';
import 'base_remote_datasource.dart';

class DebtsRemoteDataSource extends BaseRemoteDataSource {
  DebtsRemoteDataSource(FirestoreService super.fs);

  Future<void> upsert(DebtModel model) async {
    await col(FirebaseConstants.debts).doc('${model.id}').set(model.toMap());
  }

  Future<void> delete(int id) async {
    await col(FirebaseConstants.debts).doc('$id').delete();
  }

  Future<List<DebtModel>> fetchAll() async {
    final snap = await col(FirebaseConstants.debts).get();
    return snap.docs.map((d) => DebtModel.fromMap(d.data())).toList();
  }
}
