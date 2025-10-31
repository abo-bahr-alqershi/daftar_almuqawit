// ignore_for_file: public_member_api_docs

import '../../../core/services/firebase/firestore_service.dart';
import 'base_remote_datasource.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SyncRemoteDataSource extends BaseRemoteDataSource {
  SyncRemoteDataSource(FirestoreService super.fs);

  Future<void> pushOperation({
    required String entity,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    await fs.col('sync_operations').add({
      'entity': entity,
      'operation': operation,
      'payload': payload,
      'created_at': FieldValue.serverTimestamp(),
    });
  }
}
