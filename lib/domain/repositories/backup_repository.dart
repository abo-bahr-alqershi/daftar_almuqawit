// ignore_for_file: public_member_api_docs

import '../../core/services/google_drive_service.dart';

/// مستودع النسخ الاحتياطي
/// 
/// ⚠️ ملاحظة: يعمل مع Google Drive للنسخ الاحتياطي الكامل
/// للمزامنة المستمرة، استخدم storage_sync_coordinator
abstract class BackupRepository {
  Future<String> createBackup();
  Future<void> restoreBackup(String path);
  Future<void> scheduleAutoBackup();
  Future<String> exportToExcel(String dateRange);
  Future<String> uploadToCloud(String filePath);
  Future<List<DriveBackupInfo>> getCloudBackups();
  Future<void> restoreFromCloud(String driveFileId);
  Future<void> deleteCloudBackup(String driveFileId);
  Future<int> deleteOldBackups({int daysOld = 30, int keepLast = 5});
  Future<int> getUsedStorage();
  Future<bool> isCloudAvailable();
}
