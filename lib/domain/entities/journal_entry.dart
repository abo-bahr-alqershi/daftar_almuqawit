// ignore_for_file: public_member_api_docs

import 'base/base_entity.dart';

/// كيان قيد اليومية
class JournalEntry extends BaseEntity {
  final String date;
  final String time;
  final String description;
  final String? referenceType;
  final int? referenceId;
  final double totalAmount;

  const JournalEntry({
    super.id,
    required this.date,
    required this.time,
    required this.description,
    this.referenceType,
    this.referenceId,
    required this.totalAmount,
  });
}
