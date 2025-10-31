// ignore_for_file: public_member_api_docs

import '../../repositories/backup_repository.dart';
import '../base/base_usecase.dart';

class RestoreBackup implements UseCase<void, String> {
  final BackupRepository repo;
  RestoreBackup(this.repo);
  @override
  Future<void> call(String path) => repo.restoreBackup(path);
}
