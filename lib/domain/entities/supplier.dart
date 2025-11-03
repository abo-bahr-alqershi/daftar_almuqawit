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

  /// التحقق من صحة بيانات المورد
  bool isValid() {
    return name.trim().isNotEmpty && qualityRating >= 1 && qualityRating <= 5;
  }

  /// حساب متوسط قيمة المشتريات
  double get averagePurchaseValue {
    return totalPurchases;
  }

  /// التحقق من وجود ديون للمورد
  bool get hasDebt {
    return totalDebtToHim > 0;
  }

  /// تحديد مستوى الثقة بناءً على التقييم
  String getTrustLevelDescription() {
    if (qualityRating >= 4) return 'ممتاز';
    if (qualityRating >= 3) return 'جيد';
    return 'متوسط';
  }

  /// نسخ الكيان مع تحديث بعض الخصائص
  Supplier copyWith({
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
  }) {
    return Supplier(
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
  }

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        area,
        qualityRating,
        trustLevel,
        totalPurchases,
        totalDebtToHim,
        notes,
        createdAt,
      ];
}
