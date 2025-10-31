// ignore_for_file: public_member_api_docs

/// تعريف جدول قائمة المزامنة للعمليات غير المتصلة
class SyncQueueTable {
  SyncQueueTable._();
  static const String table = 'sync_queue';

  static const String cId = 'id';
  static const String cOperation = 'operation'; // insert | update | delete
  static const String cEntity = 'entity'; // اسم الجدول/الكيان
  static const String cPayload = 'payload'; // JSON
  static const String cCreatedAt = 'created_at';
  static const String cStatus = 'status'; // pending | processing | done | failed
  static const String cRetryCount = 'retry_count';

  static const String create = '''
CREATE TABLE $table (
  $cId INTEGER PRIMARY KEY AUTOINCREMENT,
  $cOperation TEXT NOT NULL,
  $cEntity TEXT NOT NULL,
  $cPayload TEXT NOT NULL,
  $cCreatedAt TEXT DEFAULT CURRENT_TIMESTAMP,
  $cStatus TEXT DEFAULT 'pending',
  $cRetryCount INTEGER DEFAULT 0
);
''';
}
