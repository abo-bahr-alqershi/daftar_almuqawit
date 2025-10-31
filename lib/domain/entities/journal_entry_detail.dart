// ignore_for_file: public_member_api_docs

import 'base/base_entity.dart';

/// كيان تفاصيل القيد
class JournalEntryDetail extends BaseEntity {
  final int entryId;
  final int accountId;
  final double debit;
  final double credit;

  const JournalEntryDetail({
    super.id,
    required this.entryId,
    required this.accountId,
    this.debit = 0,
    this.credit = 0,
  });
}
