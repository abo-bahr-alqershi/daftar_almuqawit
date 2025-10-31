// ignore_for_file: public_member_api_docs

import 'base/base_entity.dart';

/// كيان نوع القات
class QatType extends BaseEntity {
  final String name; // حرازي، مطري، ...
  final String? qualityGrade; // ممتاز، جيد، عادي
  final double? defaultBuyPrice;
  final double? defaultSellPrice;
  final String? color;
  final String? icon; // رمز تعبيري

  const QatType({
    super.id,
    required this.name,
    this.qualityGrade,
    this.defaultBuyPrice,
    this.defaultSellPrice,
    this.color,
    this.icon,
  });
}
