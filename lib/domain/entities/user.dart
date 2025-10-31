// ignore_for_file: public_member_api_docs

import 'base/base_entity.dart';

/// كيان المستخدم
class User extends BaseEntity {
  final String uid;
  final String? name;
  final String? email;

  const User({super.id, required this.uid, this.name, this.email});
}
