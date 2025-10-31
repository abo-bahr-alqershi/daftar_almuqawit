// ignore_for_file: public_member_api_docs

import '../../../core/services/firebase/firestore_service.dart';
import 'base_remote_datasource.dart';

class BackupRemoteDataSource extends BaseRemoteDataSource {
  BackupRemoteDataSource(FirestoreService super.fs);
}
