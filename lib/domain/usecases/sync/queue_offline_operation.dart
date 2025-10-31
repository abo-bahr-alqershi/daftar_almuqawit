// ignore_for_file: public_member_api_docs

import '../../repositories/sync_repository.dart';
import '../base/base_usecase.dart';

typedef QueueParams = ({String entity, String operation, Map<String, Object?> payload});

class QueueOfflineOperation implements UseCase<void, QueueParams> {
  final SyncRepository repo;
  QueueOfflineOperation(this.repo);
  @override
  Future<void> call(QueueParams params) => repo.queueOperation(params.entity, params.operation, params.payload);
}
