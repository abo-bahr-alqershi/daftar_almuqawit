// ignore_for_file: public_member_api_docs

import '../../domain/entities/journal_entry.dart';
import '../../domain/entities/journal_entry_detail.dart';
import '../../domain/repositories/accounting_repository.dart';
import '../datasources/local/accounting_local_datasource.dart';
import '../models/journal_entry_model.dart';
import '../models/journal_entry_detail_model.dart';

class AccountingRepositoryImpl implements AccountingRepository {
  final AccountingLocalDataSource local;
  AccountingRepositoryImpl(this.local);

  JournalEntryModel _toModel(JournalEntry e) => JournalEntryModel(
        id: e.id,
        date: e.date,
        time: e.time,
        description: e.description,
        referenceType: e.referenceType,
        referenceId: e.referenceId,
        totalAmount: e.totalAmount,
      );

  JournalEntryDetail _fromDetailModel(JournalEntryDetailModel m) => JournalEntryDetail(
        id: m.id,
        entryId: m.entryId,
        accountId: m.accountId,
        debit: m.debit,
        credit: m.credit,
      );

  JournalEntryDetailModel _toDetailModel(JournalEntryDetail e) => JournalEntryDetailModel(
        id: e.id,
        entryId: e.entryId,
        accountId: e.accountId,
        debit: e.debit,
        credit: e.credit,
      );

  @override
  Future<int> add(JournalEntry entity) => local.insertEntry(_toModel(entity));

  @override
  Future<int> addDetail(JournalEntryDetail detail) => local.insertDetail(_toDetailModel(detail));

  @override
  Future<void> delete(int id) async {
    // حذف القيد غير مدعوم حالياً
  }

  @override
  Future<List<JournalEntry>> getAll() async => <JournalEntry>[];

  @override
  Future<JournalEntry?> getById(int id) async => null;

  @override
  Future<double> getCashBalance() => local.getCashBalance();

  @override
  Future<List<JournalEntryDetail>> getDetails(int entryId) async => (await local.getDetails(entryId)).map(_fromDetailModel).toList();

  @override
  Future<void> update(JournalEntry entity) async {
    // تحديث القيد غير مدعوم حالياً
  }
}
