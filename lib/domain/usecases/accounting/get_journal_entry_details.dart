// ignore_for_file: public_member_api_docs

import '../../entities/journal_entry_detail.dart';
import '../../repositories/accounting_repository.dart';
import '../base/base_usecase.dart';

class GetJournalEntryDetails implements UseCase<List<JournalEntryDetail>, int> {
  final AccountingRepository repo;
  GetJournalEntryDetails(this.repo);
  @override
  Future<List<JournalEntryDetail>> call(int entryId) => repo.getDetails(entryId);
}
