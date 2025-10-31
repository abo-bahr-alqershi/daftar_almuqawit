// ignore_for_file: public_member_api_docs

import '../../entities/journal_entry.dart';
import '../../repositories/accounting_repository.dart';
import '../base/base_usecase.dart';

class AddJournalEntry implements UseCase<int, JournalEntry> {
  final AccountingRepository repo;
  AddJournalEntry(this.repo);
  @override
  Future<int> call(JournalEntry params) => repo.add(params);
}
