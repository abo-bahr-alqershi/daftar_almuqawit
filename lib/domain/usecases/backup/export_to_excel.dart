// ignore_for_file: public_member_api_docs

import '../../repositories/backup_repository.dart';
import '../base/base_usecase.dart';

class ExportToExcel implements UseCase<String, String> {
  final BackupRepository repo;
  ExportToExcel(this.repo);
  @override
  Future<String> call(String dateRange) => repo.exportToExcel(dateRange);
}
