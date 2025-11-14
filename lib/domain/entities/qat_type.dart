// ignore_for_file: public_member_api_docs

import 'base/base_entity.dart';

/// كيان نوع القات
class QatType extends BaseEntity {
  // رمز تعبيري

  const QatType({
    required this.name,
    super.id,
    this.qualityGrade,
    this.defaultBuyPrice,
    this.defaultSellPrice,
    this.color,
    this.icon,
    this.availableUnits,
    this.unitPrices,
  });
  final String name; // قيفي رووس، عنسي عوارض ...
  final String? qualityGrade; // ممتاز، جيد، عادي
  final double? defaultBuyPrice;
  final double? defaultSellPrice;
  final String? color;
  final String? icon;
  final List<String>? availableUnits; // الوحدات المتاحة: ربطة، علاقية كيلو
  final Map<String, UnitPrice>? unitPrices; // أسعار الشراء والبيع لكل وحدة
}

/// أسعار وحدة القياس
class UnitPrice {
  final double? buyPrice;
  final double? sellPrice;

  const UnitPrice({this.buyPrice, this.sellPrice});

  Map<String, dynamic> toJson() => {
    'buyPrice': buyPrice,
    'sellPrice': sellPrice,
  };

  factory UnitPrice.fromJson(Map<String, dynamic> json) => UnitPrice(
    buyPrice: (json['buyPrice'] as num?)?.toDouble(),
    sellPrice: (json['sellPrice'] as num?)?.toDouble(),
  );
}
