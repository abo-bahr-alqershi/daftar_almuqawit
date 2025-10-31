// ignore_for_file: public_member_api_docs

import '../../domain/repositories/backup_repository.dart';
import '../../core/services/backup_service.dart';

class BackupRepositoryImpl implements BackupRepository {
  final BackupService service;
  BackupRepositoryImpl(this.service);

  @override
  Future<String> createBackup() => service.createBackup();

  @override
  Future<void> restoreBackup(String path) => service.restoreBackup(path);

  @override
  Future<void> scheduleAutoBackup() async {
    // TODO: جدولة النسخ الاحتياطي التلقائي
  }

  @override
  Future<String> exportToExcel(String dateRange) async {
    // TODO: تصدير إلى إكسل
    return 'path/to/export.xlsx';
  }
}
