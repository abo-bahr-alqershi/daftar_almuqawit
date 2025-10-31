// ignore_for_file: public_member_api_docs

/// واجهة نماذج البيانات القابلة للتحويل إلى/من خريطة قاعدة البيانات
abstract class BaseModel {
  const BaseModel();
  Map<String, Object?> toMap();
}
