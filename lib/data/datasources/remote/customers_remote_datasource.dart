// ignore_for_file: public_member_api_docs

import '../../../core/constants/firebase_constants.dart';
import '../../../core/services/firebase/firestore_service.dart';
import '../../models/customer_model.dart';
import 'base_remote_datasource.dart';

class CustomersRemoteDataSource extends BaseRemoteDataSource {
  CustomersRemoteDataSource(FirestoreService super.fs);

  Future<void> upsert(CustomerModel model) async {
    await col(FirebaseConstants.customers).doc('${model.id}').set(model.toMap());
  }

  Future<void> delete(int id) async {
    await col(FirebaseConstants.customers).doc('$id').delete();
  }

  Future<List<CustomerModel>> fetchAll() async {
    final snap = await col(FirebaseConstants.customers).get();
    return snap.docs.map((d) => CustomerModel.fromMap(d.data())).toList();
  }
}
