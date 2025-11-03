import 'base/base_model.dart';
import '../database/tables/suppliers_table.dart';
import '../../domain/entities/supplier.dart';

/// نموذج المورد
/// 
/// يمثل بيانات المورد في قاعدة البيانات
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

  /// تحويل إلى كيان
  Supplier toEntity() => Supplier(
        id: id,
        name: name,
        phone: phone,
        area: area,
        qualityRating: qualityRating,
        trustLevel: trustLevel,
        totalPurchases: totalPurchases,
        totalDebtToHim: totalDebtToHim,
        notes: notes,
        createdAt: createdAt,
      );

  /// إنشاء نسخة من الكيان
  static SupplierModel fromEntity(Supplier entity) => SupplierModel(
        id: entity.id,
        name: entity.name,
        phone: entity.phone,
        area: entity.area,
        qualityRating: entity.qualityRating,
        trustLevel: entity.trustLevel,
        totalPurchases: entity.totalPurchases,
        totalDebtToHim: entity.totalDebtToHim,
        notes: entity.notes,
        createdAt: entity.createdAt,
      );

  /// نسخ مع تعديلات
  SupplierModel copyWith({
    int? id,
    String? name,
    String? phone,
    String? area,
    int? qualityRating,
    String? trustLevel,
    double? totalPurchases,
    double? totalDebtToHim,
    String? notes,
    String? createdAt,
  }) =>
      SupplierModel(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        area: area ?? this.area,
        qualityRating: qualityRating ?? this.qualityRating,
        trustLevel: trustLevel ?? this.trustLevel,
        totalPurchases: totalPurchases ?? this.totalPurchases,
        totalDebtToHim: totalDebtToHim ?? this.totalDebtToHim,
        notes: notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupplierModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
