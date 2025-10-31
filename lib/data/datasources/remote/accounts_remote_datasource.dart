// ignore_for_file: public_member_api_docs

import '../../../core/constants/firebase_constants.dart';
import '../../../core/services/firebase/firestore_service.dart';
import '../../models/account_model.dart';
import 'base_remote_datasource.dart';

class AccountsRemoteDataSource extends BaseRemoteDataSource {
  AccountsRemoteDataSource(FirestoreService super.fs);

  Future<void> upsert(AccountModel model) async {
    await col(FirebaseConstants.accounts).doc('${model.id}').set(model.toMap());
  }

  Future<void> delete(int id) async {
    await col(FirebaseConstants.accounts).doc('$id').delete();
  }

  Future<List<AccountModel>> fetchAll() async {
    final snap = await col(FirebaseConstants.accounts).get();
    return snap.docs.map((d) => AccountModel.fromMap(d.data())).toList();
  }
}
