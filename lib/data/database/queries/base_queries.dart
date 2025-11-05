// ignore_for_file: public_member_api_docs

import '../../../core/constants/database_constants.dart';

/// استعلامات قاعدة البيانات الأساسية
/// توفر استعلامات SQL شائعة قابلة لإعادة الاستخدام
class BaseQueries {
  BaseQueries._();

  /// استعلام الحصول على جميع السجلات
  static String selectAll(String tableName) {
    return '''
      SELECT * FROM $tableName 
      WHERE ${DatabaseConstants.columnIsDeleted} = 0
      ORDER BY ${DatabaseConstants.columnCreatedAt} DESC
    ''';
  }

  /// استعلام الحصول على سجل بالمعرف
  static String selectById(String tableName) {
    return '''
      SELECT * FROM $tableName 
      WHERE ${DatabaseConstants.columnId} = ? 
      AND ${DatabaseConstants.columnIsDeleted} = 0
    ''';
  }

  /// استعلام الإدراج
  static String insert(String tableName, Map<String, dynamic> data) {
    final columns = data.keys.join(', ');
    final placeholders = List.filled(data.length, '?').join(', ');
    return 'INSERT INTO $tableName ($columns) VALUES ($placeholders)';
  }

  /// استعلام التحديث
  static String update(String tableName, Map<String, dynamic> data) {
    final sets = data.keys.map((key) => '$key = ?').join(', ');
    return '''
      UPDATE $tableName 
      SET $sets, ${DatabaseConstants.columnUpdatedAt} = ?
      WHERE ${DatabaseConstants.columnId} = ?
    ''';
  }

  /// استعلام الحذف الناعم
  static String softDelete(String tableName) {
    return DatabaseConstants.softDeleteQuery(tableName);
  }

  /// استعلام الحذف النهائي
  static String hardDelete(String tableName) {
    return DatabaseConstants.hardDeleteQuery(tableName);
  }

  /// استعلام الاستعادة
  static String restore(String tableName) {
    return DatabaseConstants.restoreQuery(tableName);
  }

  /// استعلام البحث
  static String search(String tableName, List<String> columns, String searchTerm) {
    final conditions = columns.map((col) => '$col LIKE ?').join(' OR ');
    return '''
      SELECT * FROM $tableName 
      WHERE ($conditions) 
      AND ${DatabaseConstants.columnIsDeleted} = 0
      ORDER BY ${DatabaseConstants.columnCreatedAt} DESC
    ''';
  }

  /// استعلام الترقيم
  static String paginate(String tableName, int limit, int offset) {
    return '''
      SELECT * FROM $tableName 
      WHERE ${DatabaseConstants.columnIsDeleted} = 0
      ORDER BY ${DatabaseConstants.columnCreatedAt} DESC
      LIMIT $limit OFFSET $offset
    ''';
  }

  /// استعلام العد
  static String count(String tableName) {
    return '''
      SELECT COUNT(*) as count FROM $tableName 
      WHERE ${DatabaseConstants.columnIsDeleted} = 0
    ''';
  }

  /// استعلام الفلترة حسب التاريخ
  static String filterByDate(String tableName, String dateColumn) {
    return '''
      SELECT * FROM $tableName 
      WHERE DATE($dateColumn) = ? 
      AND ${DatabaseConstants.columnIsDeleted} = 0
      ORDER BY $dateColumn DESC
    ''';
  }

  /// استعلام الفلترة حسب نطاق التواريخ
  static String filterByDateRange(String tableName, String dateColumn) {
    return '''
      SELECT * FROM $tableName 
      WHERE DATE($dateColumn) BETWEEN ? AND ? 
      AND ${DatabaseConstants.columnIsDeleted} = 0
      ORDER BY $dateColumn DESC
    ''';
  }

  /// استعلام السجلات غير المتزامنة
  static String unsyncedRecords(String tableName) {
    return '''
      SELECT * FROM $tableName 
      WHERE ${DatabaseConstants.columnSyncStatus} = '${DatabaseConstants.syncStatusPending}'
      AND ${DatabaseConstants.columnIsDeleted} = 0
      ORDER BY ${DatabaseConstants.columnCreatedAt} ASC
    ''';
  }

  /// استعلام تحديث حالة المزامنة
  static String updateSyncStatus(String tableName) {
    return '''
      UPDATE $tableName 
      SET ${DatabaseConstants.columnSyncStatus} = ?,
          ${DatabaseConstants.columnLastSynced} = ?
      WHERE ${DatabaseConstants.columnId} = ?
    ''';
  }

  /// استعلام السجلات النشطة فقط
  static String activeOnly(String tableName) {
    return '''
      SELECT * FROM $tableName 
      WHERE ${DatabaseConstants.columnIsActive} = 1 
      AND ${DatabaseConstants.columnIsDeleted} = 0
      ORDER BY ${DatabaseConstants.columnCreatedAt} DESC
    ''';
  }

  /// استعلام الفرز
  static String orderBy(String tableName, String column, {bool ascending = false}) {
    final order = ascending ? 'ASC' : 'DESC';
    return '''
      SELECT * FROM $tableName 
      WHERE ${DatabaseConstants.columnIsDeleted} = 0
      ORDER BY $column $order
    ''';
  }

  /// استعلام الحصول على آخر سجل
  static String getLatest(String tableName) {
    return '''
      SELECT * FROM $tableName 
      WHERE ${DatabaseConstants.columnIsDeleted} = 0
      ORDER BY ${DatabaseConstants.columnCreatedAt} DESC
      LIMIT 1
    ''';
  }

  /// استعلام التحقق من الوجود
  static String exists(String tableName, String column) {
    return '''
      SELECT EXISTS(
        SELECT 1 FROM $tableName 
        WHERE $column = ? 
        AND ${DatabaseConstants.columnIsDeleted} = 0
      ) as exists
    ''';
  }
}
