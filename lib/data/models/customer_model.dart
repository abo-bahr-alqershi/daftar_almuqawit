// ignore_for_file: public_member_api_docs

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
  final String? createdAt;

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
  });

  factory CustomerModel.fromMap(Map<String, Object?> map) => CustomerModel(
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
        createdAt: map[CustomersTable.cCreatedAt] as String?,
      );

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
        CustomersTable.cCreatedAt: createdAt,
      };
}
