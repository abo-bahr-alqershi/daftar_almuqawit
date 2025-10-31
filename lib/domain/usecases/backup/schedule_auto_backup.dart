// ignore_for_file: public_member_api_docs

import '../../repositories/backup_repository.dart';
import '../base/base_usecase.dart';

class ScheduleAutoBackup implements UseCase<void, NoParams> {
  final BackupRepository repo;
  ScheduleAutoBackup(this.repo);
  @override
  Future<void> call(NoParams params) => repo.scheduleAutoBackup();
}
