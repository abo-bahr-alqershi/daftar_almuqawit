// ignore_for_file: public_member_api_docs

import 'base/base_model.dart';
import '../database/tables/journal_entry_details_table.dart';

class JournalEntryDetailModel extends BaseModel {
  final int? id;
  final int entryId;
  final int accountId;
  final double debit;
  final double credit;

  const JournalEntryDetailModel({
    this.id,
    required this.entryId,
    required this.accountId,
    this.debit = 0,
    this.credit = 0,
  });

  factory JournalEntryDetailModel.fromMap(Map<String, Object?> map) => JournalEntryDetailModel(
        id: map[JournalEntryDetailsTable.cId] as int?,
        entryId: map[JournalEntryDetailsTable.cEntryId] as int,
        accountId: map[JournalEntryDetailsTable.cAccountId] as int,
        debit: (map[JournalEntryDetailsTable.cDebit] as num?)?.toDouble() ?? 0,
        credit: (map[JournalEntryDetailsTable.cCredit] as num?)?.toDouble() ?? 0,
      );

  @override
  Map<String, Object?> toMap() => {
        JournalEntryDetailsTable.cId: id,
        JournalEntryDetailsTable.cEntryId: entryId,
        JournalEntryDetailsTable.cAccountId: accountId,
        JournalEntryDetailsTable.cDebit: debit,
        JournalEntryDetailsTable.cCredit: credit,
      };

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'entryId': entryId,
        'accountId': accountId,
        'debit': debit,
        'credit': credit,
      };

  @override
  JournalEntryDetailModel copyWith({
    int? id,
    int? entryId,
    int? accountId,
    double? debit,
    double? credit,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? firebaseId,
    String? syncStatus,
  }) =>
      JournalEntryDetailModel(
        id: id ?? this.id,
        entryId: entryId ?? this.entryId,
        accountId: accountId ?? this.accountId,
        debit: debit ?? this.debit,
        credit: credit ?? this.credit,
      );

  @override
  List<Object?> get props => [id, entryId, accountId, debit, credit];
}
