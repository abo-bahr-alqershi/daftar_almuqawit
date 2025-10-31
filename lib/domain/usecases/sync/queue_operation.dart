// ignore_for_file: public_member_api_docs

import '../../repositories/sync_repository.dart';
import '../base/base_usecase.dart';

class QueueOperation implements UseCase<void, ({String entity, String operation, Map<String, Object?> payload})> {
  final SyncRepository repo;
  QueueOperation(this.repo);
  @override
  Future<void> call(({String entity, String operation, Map<String, Object?> payload}) params) =>
      repo.queueOperation(params.entity, params.operation, params.payload);
}
