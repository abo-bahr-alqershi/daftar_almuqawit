// ignore_for_file: public_member_api_docs

import '../../../core/constants/firebase_constants.dart';
import '../../../core/services/firebase/firestore_service.dart';
import '../../models/debt_payment_model.dart';
import 'base_remote_datasource.dart';

class DebtPaymentsRemoteDataSource extends BaseRemoteDataSource {
  DebtPaymentsRemoteDataSource(FirestoreService super.fs);

  Future<void> upsert(DebtPaymentModel model) async {
    await col(FirebaseConstants.debtPayments).doc('${model.id}').set(model.toMap());
  }

  Future<void> delete(int id) async {
    await col(FirebaseConstants.debtPayments).doc('$id').delete();
  }

  Future<List<DebtPaymentModel>> fetchByDebt(int debtId) async {
    final snap = await col(FirebaseConstants.debtPayments).where('debt_id', isEqualTo: debtId).get();
    return snap.docs.map((d) => DebtPaymentModel.fromMap(d.data())).toList();
  }
}
