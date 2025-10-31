// ignore_for_file: public_member_api_docs

import '../../../core/constants/firebase_constants.dart';
import '../../../core/services/firebase/firestore_service.dart';
import '../../models/supplier_model.dart';
import 'base_remote_datasource.dart';

class SuppliersRemoteDataSource extends BaseRemoteDataSource {
  SuppliersRemoteDataSource(super.fs);

  Future<void> upsert(SupplierModel model) async {
    final doc = col(FirebaseConstants.suppliers).doc('${model.id}');
    await doc.set(model.toMap());
  }

  Future<void> delete(int id) async {
    await col(FirebaseConstants.suppliers).doc('$id').delete();
  }

  Future<List<SupplierModel>> fetchAll() async {
    final snap = await col(FirebaseConstants.suppliers).get();
    return snap.docs.map((d) => SupplierModel.fromMap(d.data())).toList();
  }

  Future<SupplierModel?> fetchById(int id) async {
    final doc = await col(FirebaseConstants.suppliers).doc('$id').get();
    if (!doc.exists) return null;
    return SupplierModel.fromMap(doc.data()!);
  }
}
