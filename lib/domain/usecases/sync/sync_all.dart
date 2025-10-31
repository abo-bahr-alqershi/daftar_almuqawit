// ignore_for_file: public_member_api_docs

import '../../entities/sync_status.dart';
import '../../repositories/sync_repository.dart';
import '../base/base_usecase.dart';

class SyncAll implements UseCase<SyncStatus, NoParams> {
  final SyncRepository repo;
  SyncAll(this.repo);
  @override
  Future<SyncStatus> call(NoParams params) => repo.syncAll();
}
