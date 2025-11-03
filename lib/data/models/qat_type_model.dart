// ignore_for_file: public_member_api_docs

import 'base/base_model.dart';
import '../database/tables/qat_types_table.dart';

class QatTypeModel extends BaseModel {
  final int? id;
  final String name;
  final String? qualityGrade;
  final double? defaultBuyPrice;
  final double? defaultSellPrice;
  final String? color;
  final String? icon;

  const QatTypeModel({
    this.id,
    required this.name,
    this.qualityGrade,
    this.defaultBuyPrice,
    this.defaultSellPrice,
    this.color,
    this.icon,
  });

  factory QatTypeModel.fromMap(Map<String, Object?> map) => QatTypeModel(
        id: map[QatTypesTable.cId] as int?,
        name: map[QatTypesTable.cName] as String,
        qualityGrade: map[QatTypesTable.cQualityGrade] as String?,
        defaultBuyPrice: (map[QatTypesTable.cDefaultBuyPrice] as num?)?.toDouble(),
        defaultSellPrice: (map[QatTypesTable.cDefaultSellPrice] as num?)?.toDouble(),
        color: map[QatTypesTable.cColor] as String?,
        icon: map[QatTypesTable.cIcon] as String?,
      );

  @override
  Map<String, Object?> toMap() => {
        QatTypesTable.cId: id,
        QatTypesTable.cName: name,
        QatTypesTable.cQualityGrade: qualityGrade,
        QatTypesTable.cDefaultBuyPrice: defaultBuyPrice,
        QatTypesTable.cDefaultSellPrice: defaultSellPrice,
        QatTypesTable.cColor: color,
        QatTypesTable.cIcon: icon,
      };

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'qualityGrade': qualityGrade,
        'defaultBuyPrice': defaultBuyPrice,
        'defaultSellPrice': defaultSellPrice,
        'color': color,
        'icon': icon,
      };

  @override
  QatTypeModel copyWith({
    int? id,
    String? name,
    String? qualityGrade,
    double? defaultBuyPrice,
    double? defaultSellPrice,
    String? color,
    String? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? firebaseId,
    String? syncStatus,
  }) =>
      QatTypeModel(
        id: id ?? this.id,
        name: name ?? this.name,
        qualityGrade: qualityGrade ?? this.qualityGrade,
        defaultBuyPrice: defaultBuyPrice ?? this.defaultBuyPrice,
        defaultSellPrice: defaultSellPrice ?? this.defaultSellPrice,
        color: color ?? this.color,
        icon: icon ?? this.icon,
      );

  @override
  List<Object?> get props => [id, name, qualityGrade, defaultBuyPrice, defaultSellPrice, color, icon];
}
