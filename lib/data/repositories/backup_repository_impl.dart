// ignore_for_file: public_member_api_docs

import '../../domain/repositories/backup_repository.dart';
import '../../core/services/backup_service.dart';
import '../../core/services/export_service.dart';
import '../../core/services/google_drive_service.dart';

/// تطبيق مستودع النسخ الاحتياطي
/// 
/// ⚠️ ملاحظة: يستخدم Google Drive للنسخ الاحتياطي فقط
/// للمزامنة بين الأجهزة، استخدم storage_sync_coordinator
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
  Future<String> exportToExcel(String dateRange) async {
    return await exportService.toExcel(
      dateRange,
      title: 'تقرير دفتر المقوت',
      headers: ['التاريخ', 'النوع', 'المبلغ', 'التفاصيل'],
      data: [],
    );
  }
  
  @override
  Future<String> uploadToCloud(String filePath) async {
    try {
      // رفع إلى Google Drive (للنسخ الاحتياطي)
      return await service.createBackupToDrive();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<DriveBackupInfo>> getCloudBackups() async {
    return await service.getCloudBackups();
  }

  @override
  Future<void> restoreFromCloud(String driveFileId) async {
    await service.restoreFromDrive(driveFileId);
  }

  @override
  Future<void> deleteCloudBackup(String driveFileId) async {
    await service.deleteCloudBackup(driveFileId);
  }

  @override
  Future<int> deleteOldBackups({int daysOld = 30, int keepLast = 5}) async {
    return await service.deleteOldBackups(daysOld: daysOld, keepLast: keepLast);
  }

  @override
  Future<int> getUsedStorage() async {
    return await service.getUsedStorage();
  }

  @override
  Future<bool> isCloudAvailable() async {
    return await service.isCloudAvailable();
  }
}

