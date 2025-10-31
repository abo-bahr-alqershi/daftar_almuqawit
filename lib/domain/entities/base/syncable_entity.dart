// ignore_for_file: public_member_api_docs

import 'base_entity.dart';

/// كيان قابل للمزامنة مع السحابة
abstract class SyncableEntity extends BaseEntity {
  final String? createdAt;
  final String? updatedAt;
  const SyncableEntity({super.id, this.createdAt, this.updatedAt});
}
