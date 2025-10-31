// ignore_for_file: public_member_api_docs

import '../../../core/constants/firebase_constants.dart';
import '../../../core/services/firebase/firestore_service.dart';
import '../../models/expense_model.dart';
import 'base_remote_datasource.dart';

class ExpensesRemoteDataSource extends BaseRemoteDataSource {
  ExpensesRemoteDataSource(FirestoreService super.fs);

  Future<void> upsert(ExpenseModel model) async {
    await col(FirebaseConstants.expenses).doc('${model.id}').set(model.toMap());
  }

  Future<void> delete(int id) async {
    await col(FirebaseConstants.expenses).doc('$id').delete();
  }

  Future<List<ExpenseModel>> fetchAll() async {
    final snap = await col(FirebaseConstants.expenses).get();
    return snap.docs.map((d) => ExpenseModel.fromMap(d.data())).toList();
  }
}
