// ignore_for_file: public_member_api_docs

import 'base/base_model.dart';
import '../database/tables/accounts_table.dart';

class AccountModel extends BaseModel {
  final int? id;
  final String name;
  final String type;
  final double balance;
  final String? icon;
  final String? color;

  const AccountModel({
    this.id,
    required this.name,
    required this.type,
    this.balance = 0,
    this.icon,
    this.color,
  });

  factory AccountModel.fromMap(Map<String, Object?> map) => AccountModel(
        id: map[AccountsTable.cId] as int?,
        name: map[AccountsTable.cName] as String,
        type: map[AccountsTable.cType] as String,
        balance: (map[AccountsTable.cBalance] as num?)?.toDouble() ?? 0,
        icon: map[AccountsTable.cIcon] as String?,
        color: map[AccountsTable.cColor] as String?,
      );

  @override
  Map<String, Object?> toMap() => {
        AccountsTable.cId: id,
        AccountsTable.cName: name,
        AccountsTable.cType: type,
        AccountsTable.cBalance: balance,
        AccountsTable.cIcon: icon,
        AccountsTable.cColor: color,
      };

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'balance': balance,
        'icon': icon,
        'color': color,
      };

  @override
  AccountModel copyWith({
    int? id,
    String? name,
    String? type,
    double? balance,
    String? icon,
    String? color,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? firebaseId,
    String? syncStatus,
  }) =>
      AccountModel(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        balance: balance ?? this.balance,
        icon: icon ?? this.icon,
        color: color ?? this.color,
      );

  @override
  List<Object?> get props => [id, name, type, balance, icon, color];
}
