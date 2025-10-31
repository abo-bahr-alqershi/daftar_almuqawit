// ignore_for_file: public_member_api_docs

import 'base_model.dart';

/// نموذج يدعم حقول المزامنة الأساسية
abstract class SyncableModel extends BaseModel {
  final int? id;
  const SyncableModel({this.id});
}
