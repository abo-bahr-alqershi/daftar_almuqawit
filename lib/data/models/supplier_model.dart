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
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final String? firebaseId;
  @override
  final String? syncStatus;

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
    this.updatedAt,
    this.firebaseId,
    this.syncStatus,
  });

  factory SupplierModel.fromMap(Map<String, Object?> map) {
    final createdAtStr = map[SuppliersTable.cCreatedAt] as String?;
    return SupplierModel(
      id: map[SuppliersTable.cId] as int?,
      name: map[SuppliersTable.cName] as String,
      phone: map[SuppliersTable.cPhone] as String?,
      area: map[SuppliersTable.cArea] as String?,
      qualityRating: (map[SuppliersTable.cQualityRating] as int?) ?? 3,
      trustLevel: (map[SuppliersTable.cTrustLevel] as String?) ?? 'جديد',
      totalPurchases: (map[SuppliersTable.cTotalPurchases] as num?)?.toDouble() ?? 0,
      totalDebtToHim: (map[SuppliersTable.cTotalDebtToHim] as num?)?.toDouble() ?? 0,
      notes: map[SuppliersTable.cNotes] as String?,
      createdAt: createdAtStr != null ? DateTime.tryParse(createdAtStr) : null,
      updatedAt: null,
      firebaseId: null,
      syncStatus: null,
    );
  }
  
  /// إنشاء نموذج من JSON
  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      area: json['area'] as String?,
      qualityRating: (json['qualityRating'] as int?) ?? 3,
      trustLevel: (json['trustLevel'] as String?) ?? 'جديد',
      totalPurchases: (json['totalPurchases'] as num?)?.toDouble() ?? 0,
      totalDebtToHim: (json['totalDebtToHim'] as num?)?.toDouble() ?? 0,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
      firebaseId: json['firebaseId'] as String?,
      syncStatus: json['syncStatus'] as String?,
    );
  }

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
        SuppliersTable.cCreatedAt: createdAt?.toIso8601String(),
      };

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'area': area,
        'qualityRating': qualityRating,
        'trustLevel': trustLevel,
        'totalPurchases': totalPurchases,
        'totalDebtToHim': totalDebtToHim,
        'notes': notes,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'firebaseId': firebaseId,
        'syncStatus': syncStatus,
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
        createdAt: createdAt?.toIso8601String(),
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
        createdAt: entity.createdAt != null ? DateTime.tryParse(entity.createdAt!) : null,
      );

  /// نسخ مع تعديلات
  @override
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
    DateTime? createdAt,
    DateTime? updatedAt,
    String? firebaseId,
    String? syncStatus,
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
        updatedAt: updatedAt ?? this.updatedAt,
        firebaseId: firebaseId ?? this.firebaseId,
        syncStatus: syncStatus ?? this.syncStatus,
      );

  @override
  List<Object?> get props => [id, name, phone, area, qualityRating, trustLevel, totalPurchases, totalDebtToHim, notes, createdAt, updatedAt, firebaseId, syncStatus];
}
