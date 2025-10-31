// ignore_for_file: public_member_api_docs

import 'base/base_model.dart';
import '../database/tables/suppliers_table.dart';

class SupplierModel extends BaseModel {
  final int? id;
  final String name;
  final String? phone;
  final String? area;
  final int qualityRating;
  final String trustLevel;
  final double totalPurchases;
  final double totalDebtToHim;
  final String? notes;
  final String? createdAt;

  const SupplierModel({
    this.id,
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

  factory SupplierModel.fromMap(Map<String, Object?> map) => SupplierModel(
        id: map[SuppliersTable.cId] as int?,
        name: map[SuppliersTable.cName] as String,
        phone: map[SuppliersTable.cPhone] as String?,
        area: map[SuppliersTable.cArea] as String?,
        qualityRating: (map[SuppliersTable.cQualityRating] as int?) ?? 3,
        trustLevel: (map[SuppliersTable.cTrustLevel] as String?) ?? 'جديد',
        totalPurchases: (map[SuppliersTable.cTotalPurchases] as num?)?.toDouble() ?? 0,
        totalDebtToHim: (map[SuppliersTable.cTotalDebtToHim] as num?)?.toDouble() ?? 0,
        notes: map[SuppliersTable.cNotes] as String?,
        createdAt: map[SuppliersTable.cCreatedAt] as String?,
      );

  @override
  Map<String, Object?> toMap() => {
        SuppliersTable.cId: id,
        SuppliersTable.cName: name,
        SuppliersTable.cPhone: phone,
        SuppliersTable.cArea: area,
        SuppliersTable.cQualityRating: qualityRating,
        SuppliersTable.cTrustLevel: trustLevel,
        SuppliersTable.cTotalPurchases: totalPurchases,
        SuppliersTable.cTotalDebtToHim: totalDebtToHim,
        SuppliersTable.cNotes: notes,
        SuppliersTable.cCreatedAt: createdAt,
      };
}
