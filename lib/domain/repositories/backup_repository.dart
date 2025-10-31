// ignore_for_file: public_member_api_docs

abstract class BackupRepository {
  Future<String> createBackup();
  Future<void> restoreBackup(String path);
  Future<void> scheduleAutoBackup();
  Future<String> exportToExcel(String dateRange);
}
