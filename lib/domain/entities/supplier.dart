// ignore_for_file: public_member_api_docs

import 'base/base_entity.dart';

/// كيان المورد
class Supplier extends BaseEntity {
  final String name;
  final String? phone;
  final String? area;
  final int qualityRating;
  final String trustLevel;
  final double totalPurchases;
  final double totalDebtToHim;
  final String? notes;
  final String? createdAt;

  const Supplier({
    super.id,
    required this.name,
    this.phone,
    this.area,
    this.qualityRating = 3,
    this.trustLevel = 'جديد',
    this.totalPurchases = 0,
    this.totalDebtToHim = 0,
    this.notes,
    this.createdAt,
  });
}
