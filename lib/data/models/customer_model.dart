// ignore_for_file: public_member_api_docs

import '../../domain/entities/customer.dart';
import 'base/base_model.dart';
import '../database/tables/customers_table.dart';

class CustomerModel extends BaseModel {
  final int? id;
  final String name;
  final String? phone;
  final String? nickname;
  final String customerType;
  final double creditLimit;
  final double totalPurchases;
  final double currentDebt;
  final int isBlocked;
  final String? notes;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final String? firebaseId;
  @override
  final String? syncStatus;

  const CustomerModel({
    this.id,
    required this.name,
    this.phone,
    this.nickname,
    this.customerType = 'عادي',
    this.creditLimit = 0,
    this.totalPurchases = 0,
    this.currentDebt = 0,
    this.isBlocked = 0,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.firebaseId,
    this.syncStatus,
  });

  factory CustomerModel.fromMap(Map<String, Object?> map) {
    final createdAtStr = map[CustomersTable.cCreatedAt] as String?;
    return CustomerModel(
      id: map[CustomersTable.cId] as int?,
      name: map[CustomersTable.cName] as String,
      phone: map[CustomersTable.cPhone] as String?,
      nickname: map[CustomersTable.cNickname] as String?,
      customerType: (map[CustomersTable.cCustomerType] as String?) ?? 'عادي',
      creditLimit: (map[CustomersTable.cCreditLimit] as num?)?.toDouble() ?? 0,
      totalPurchases: (map[CustomersTable.cTotalPurchases] as num?)?.toDouble() ?? 0,
      currentDebt: (map[CustomersTable.cCurrentDebt] as num?)?.toDouble() ?? 0,
      isBlocked: (map[CustomersTable.cIsBlocked] as int?) ?? 0,
      notes: map[CustomersTable.cNotes] as String?,
      createdAt: createdAtStr != null ? DateTime.tryParse(createdAtStr) : null,
      updatedAt: null,
      firebaseId: null,
      syncStatus: null,
    );
  }

  @override
  Map<String, Object?> toMap() => {
        CustomersTable.cId: id,
        CustomersTable.cName: name,
        CustomersTable.cPhone: phone,
        CustomersTable.cNickname: nickname,
        CustomersTable.cCustomerType: customerType,
        CustomersTable.cCreditLimit: creditLimit,
        CustomersTable.cTotalPurchases: totalPurchases,
        CustomersTable.cCurrentDebt: currentDebt,
        CustomersTable.cIsBlocked: isBlocked,
        CustomersTable.cNotes: notes,
        CustomersTable.cCreatedAt: createdAt?.toIso8601String(),
      };

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'nickname': nickname,
        'customerType': customerType,
        'creditLimit': creditLimit,
        'totalPurchases': totalPurchases,
        'currentDebt': currentDebt,
        'isBlocked': isBlocked,
        'notes': notes,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'firebaseId': firebaseId,
        'syncStatus': syncStatus,
      };

  @override
  CustomerModel copyWith({
    int? id,
    String? name,
    String? phone,
    String? nickname,
    String? customerType,
    double? creditLimit,
    double? totalPurchases,
    double? currentDebt,
    int? isBlocked,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? firebaseId,
    String? syncStatus,
  }) =>
      CustomerModel(
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
        updatedAt: updatedAt ?? this.updatedAt,
        firebaseId: firebaseId ?? this.firebaseId,
        syncStatus: syncStatus ?? this.syncStatus,
      );

  /// تحويل إلى كيان
  Customer toEntity() => Customer(
        id: id,
        name: name,
        phone: phone,
        nickname: nickname,
        customerType: customerType,
        creditLimit: creditLimit,
        totalPurchases: totalPurchases,
        currentDebt: currentDebt,
        isBlocked: isBlocked == 1, // تحويل من int إلى bool
        notes: notes,
        createdAt: createdAt?.toIso8601String(),
      );

  /// إنشاء من كيان
  factory CustomerModel.fromEntity(Customer entity) => CustomerModel(
        id: entity.id,
        name: entity.name,
        phone: entity.phone,
        nickname: entity.nickname,
        customerType: entity.customerType,
        creditLimit: entity.creditLimit,
        totalPurchases: entity.totalPurchases,
        currentDebt: entity.currentDebt,
        isBlocked: entity.isBlocked ? 1 : 0, // تحويل من bool إلى int
        notes: entity.notes,
        createdAt: entity.createdAt != null ? DateTime.tryParse(entity.createdAt!) : null,
      );

  @override
  List<Object?> get props => [id, name, phone, nickname, customerType, creditLimit, totalPurchases, currentDebt, isBlocked, notes, createdAt, updatedAt, firebaseId, syncStatus];
}
