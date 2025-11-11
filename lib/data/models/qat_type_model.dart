// ignore_for_file: public_member_api_docs

import 'dart:convert';
import 'base/base_model.dart';
import '../database/tables/qat_types_table.dart';
import '../../domain/entities/qat_type.dart';

class QatTypeModel extends BaseModel {
  final int? id;
  final String name;
  final String? qualityGrade;
  final double? defaultBuyPrice;
  final double? defaultSellPrice;
  final String? color;
  final String? icon;
  final List<String>? availableUnits;
  final Map<String, UnitPrice>? unitPrices;

  const QatTypeModel({
    this.id,
    required this.name,
    this.qualityGrade,
    this.defaultBuyPrice,
    this.defaultSellPrice,
    this.color,
    this.icon,
    this.availableUnits,
    this.unitPrices,
  });

  factory QatTypeModel.fromMap(Map<String, Object?> map) {
    List<String>? units;
    if (map[QatTypesTable.cAvailableUnits] != null) {
      final unitsStr = map[QatTypesTable.cAvailableUnits] as String;
      units = unitsStr.split(',').where((u) => u.isNotEmpty).toList();
    }

    Map<String, UnitPrice>? prices;
    if (map[QatTypesTable.cUnitPrices] != null) {
      final pricesStr = map[QatTypesTable.cUnitPrices] as String;
      final pricesJson = json.decode(pricesStr) as Map<String, dynamic>;
      prices = pricesJson.map(
        (key, value) => MapEntry(key, UnitPrice.fromJson(value as Map<String, dynamic>)),
      );
    }

    return QatTypeModel(
      id: map[QatTypesTable.cId] as int?,
      name: map[QatTypesTable.cName] as String,
      qualityGrade: map[QatTypesTable.cQualityGrade] as String?,
      defaultBuyPrice: (map[QatTypesTable.cDefaultBuyPrice] as num?)?.toDouble(),
      defaultSellPrice: (map[QatTypesTable.cDefaultSellPrice] as num?)?.toDouble(),
      color: map[QatTypesTable.cColor] as String?,
      icon: map[QatTypesTable.cIcon] as String?,
      availableUnits: units,
      unitPrices: prices,
    );
  }

  @override
  Map<String, Object?> toMap() => {
        QatTypesTable.cId: id,
        QatTypesTable.cName: name,
        QatTypesTable.cQualityGrade: qualityGrade,
        QatTypesTable.cDefaultBuyPrice: defaultBuyPrice,
        QatTypesTable.cDefaultSellPrice: defaultSellPrice,
        QatTypesTable.cColor: color,
        QatTypesTable.cIcon: icon,
        QatTypesTable.cAvailableUnits: availableUnits?.join(','),
        QatTypesTable.cUnitPrices: unitPrices != null
            ? json.encode(unitPrices!.map((key, value) => MapEntry(key, value.toJson())))
            : null,
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
        'availableUnits': availableUnits,
        'unitPrices': unitPrices?.map((key, value) => MapEntry(key, value.toJson())),
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
    List<String>? availableUnits,
    Map<String, UnitPrice>? unitPrices,
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
        availableUnits: availableUnits ?? this.availableUnits,
        unitPrices: unitPrices ?? this.unitPrices,
      );

  @override
  List<Object?> get props => [id, name, qualityGrade, defaultBuyPrice, defaultSellPrice, color, icon, availableUnits, unitPrices];
}
