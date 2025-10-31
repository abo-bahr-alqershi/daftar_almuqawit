// ignore_for_file: public_member_api_docs

import '../../domain/repositories/backup_repository.dart';
import '../../core/services/backup_service.dart';
import '../../core/services/export_service.dart';

class BackupRepositoryImpl implements BackupRepository {
  final BackupService service;
  final ExportService exportService;
  BackupRepositoryImpl(this.service, this.exportService);

  @override
  Future<String> createBackup() => service.createBackup();

  @override
  Future<void> restoreBackup(String path) => service.restoreBackup(path);

  @override
  Future<void> scheduleAutoBackup() async {
    await service.scheduleAutoBackup();
  }

  @override
  Future<String> exportToExcel(String dateRange) async => exportService.toExcel(dateRange);
}
