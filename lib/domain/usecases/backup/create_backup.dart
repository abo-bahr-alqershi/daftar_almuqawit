// ignore_for_file: public_member_api_docs

import '../../repositories/backup_repository.dart';
import '../base/base_usecase.dart';

class CreateBackup implements UseCase<String, NoParams> {
  final BackupRepository repo;
  CreateBackup(this.repo);
  @override
  Future<String> call(NoParams params) => repo.createBackup();
}
