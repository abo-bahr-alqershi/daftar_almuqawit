// ignore_for_file: public_member_api_docs

import '../../entities/journal_entry_detail.dart';
import '../../repositories/accounting_repository.dart';
import '../base/base_usecase.dart';

class AddJournalEntryDetail implements UseCase<int, JournalEntryDetail> {
  final AccountingRepository repo;
  AddJournalEntryDetail(this.repo);
  @override
  Future<int> call(JournalEntryDetail params) => repo.addDetail(params);
}
