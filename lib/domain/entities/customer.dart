// ignore_for_file: public_member_api_docs

import 'base/base_entity.dart';

/// كيان العميل
class Customer extends BaseEntity {
  final String name;
  final String? phone;
  final String? nickname;
  final String customerType; // VIP | عادي | جديد
  final double creditLimit;
  final double totalPurchases;
  final double currentDebt;
  final bool isBlocked;
  final String? notes;
  final String? createdAt;

  const Customer({
    super.id,
    required this.name,
    this.phone,
    this.nickname,
    this.customerType = 'عادي',
    this.creditLimit = 0,
    this.totalPurchases = 0,
    this.currentDebt = 0,
    this.isBlocked = false,
    this.notes,
    this.createdAt,
  });
}
