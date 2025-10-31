// ignore_for_file: public_member_api_docs

/// تعريف جدول البيانات الوصفية metadata
class MetadataTable {
  MetadataTable._();
  static const String table = 'metadata';

  static const String cKey = 'key';
  static const String cValue = 'value';

  static const String create = '''
CREATE TABLE $table (
  $cKey TEXT PRIMARY KEY,
  $cValue TEXT
);
''';
}
