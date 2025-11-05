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

  /// التحقق من صحة بيانات العميل
  bool isValid() {
    return name.trim().isNotEmpty;
  }

  /// حساب الرصيد المستحق (الدين الحالي)
  double get outstandingBalance {
    return currentDebt;
  }

  /// التحقق من تجاوز حد الائتمان
  bool get hasExceededCreditLimit {
    return currentDebt > creditLimit;
  }

  /// التحقق من إمكانية البيع للعميل
  bool canPurchase(double amount) {
    if (isBlocked) return false;
    if (creditLimit == 0) return true; // لا يوجد حد ائتماني
    return (currentDebt + amount) <= creditLimit;
  }

  /// حساب نسبة استخدام الائتمان
  double get creditUtilizationPercentage {
    if (creditLimit == 0) return 0;
    return (currentDebt / creditLimit) * 100;
  }

  /// تحديد حالة العميل
  String getCustomerStatus() {
    if (isBlocked) return 'محظور';
    if (hasExceededCreditLimit) return 'تجاوز الحد';
    if (currentDebt > 0) return 'عليه دين';
    return 'نشط';
  }

  /// نسخ الكيان مع تحديث بعض الخصائص
  Customer copyWith({
    int? id,
    String? name,
    String? phone,
    String? nickname,
    String? customerType,
    double? creditLimit,
    double? totalPurchases,
    double? currentDebt,
    bool? isBlocked,
    String? notes,
    String? createdAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      nickname: nickname ?? this.nickname,
      customerType: customerType ?? this.customerType,
      creditLimit: creditLimit ?? this.creditLimit,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      currentDebt: currentDebt ?? this.currentDebt,
      isBlocked: isBlocked ?? this.isBlocked,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        nickname,
        customerType,
        creditLimit,
        totalPurchases,
        currentDebt,
        isBlocked,
        notes,
        createdAt,
      ];

  /// تحويل العميل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'nickname': nickname,
      'customer_type': customerType,
      'credit_limit': creditLimit,
      'total_purchases': totalPurchases,
      'current_debt': currentDebt,
      'is_blocked': isBlocked,
      'notes': notes,
      'created_at': createdAt,
    };
  }
}
