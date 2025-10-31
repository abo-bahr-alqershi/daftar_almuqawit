// ignore_for_file: public_member_api_docs

import '../entities/journal_entry.dart';
import '../entities/journal_entry_detail.dart';
import 'base/base_repository.dart';

abstract class AccountingRepository extends BaseRepository<JournalEntry> {
  Future<int> addDetail(JournalEntryDetail detail);
  Future<List<JournalEntryDetail>> getDetails(int entryId);
  Future<double> getCashBalance();
}
