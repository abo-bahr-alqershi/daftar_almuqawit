// ignore_for_file: public_member_api_docs

import 'base/base_entity.dart';

/// كيان الحساب المالي
class Account extends BaseEntity {
  final String name; // الصندوق، رأس المال، ...
  final String type; // أصول، خصوم، إيرادات، مصروفات
  final double balance;
  final String? icon;
  final String? color;

  const Account({
    super.id,
    required this.name,
    required this.type,
    this.balance = 0,
    this.icon,
    this.color,
  });
}
