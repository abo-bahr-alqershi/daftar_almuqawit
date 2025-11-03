// ignore_for_file: public_member_api_docs

import 'base/base_model.dart';
import '../database/tables/journal_entries_table.dart';

class JournalEntryModel extends BaseModel {
  final int? id;
  final String date;
  final String time;
  final String description;
  final String? referenceType;
  final int? referenceId;
  final double totalAmount;

  const JournalEntryModel({
    this.id,
    required this.date,
    required this.time,
    required this.description,
    this.referenceType,
    this.referenceId,
    required this.totalAmount,
  });

  factory JournalEntryModel.fromMap(Map<String, Object?> map) => JournalEntryModel(
        id: map[JournalEntriesTable.cId] as int?,
        date: map[JournalEntriesTable.cDate] as String,
        time: map[JournalEntriesTable.cTime] as String,
        description: map[JournalEntriesTable.cDescription] as String,
        referenceType: map[JournalEntriesTable.cReferenceType] as String?,
        referenceId: map[JournalEntriesTable.cReferenceId] as int?,
        totalAmount: (map[JournalEntriesTable.cTotalAmount] as num).toDouble(),
      );

  @override
  Map<String, Object?> toMap() => {
        JournalEntriesTable.cId: id,
        JournalEntriesTable.cDate: date,
        JournalEntriesTable.cTime: time,
        JournalEntriesTable.cDescription: description,
        JournalEntriesTable.cReferenceType: referenceType,
        JournalEntriesTable.cReferenceId: referenceId,
        JournalEntriesTable.cTotalAmount: totalAmount,
      };

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'time': time,
        'description': description,
        'referenceType': referenceType,
        'referenceId': referenceId,
        'totalAmount': totalAmount,
      };

  @override
  JournalEntryModel copyWith({
    int? id,
    String? date,
    String? time,
    String? description,
    String? referenceType,
    int? referenceId,
    double? totalAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? firebaseId,
    String? syncStatus,
  }) =>
      JournalEntryModel(
        id: id ?? this.id,
        date: date ?? this.date,
        time: time ?? this.time,
        description: description ?? this.description,
        referenceType: referenceType ?? this.referenceType,
        referenceId: referenceId ?? this.referenceId,
        totalAmount: totalAmount ?? this.totalAmount,
      );

  @override
  List<Object?> get props => [id, date, time, description, referenceType, referenceId, totalAmount];
}
