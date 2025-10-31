// ignore_for_file: public_member_api_docs

import '../../../core/constants/firebase_constants.dart';
import '../../../core/services/firebase/firestore_service.dart';
import '../../models/journal_entry_model.dart';
import 'base_remote_datasource.dart';

class JournalEntriesRemoteDataSource extends BaseRemoteDataSource {
  JournalEntriesRemoteDataSource(FirestoreService fs) : super(fs);

  Future<void> upsert(JournalEntryModel model) async {
    await col(FirebaseConstants.journalEntries).doc('${model.id}').set(model.toMap());
  }

  Future<void> delete(int id) async {
    await col(FirebaseConstants.journalEntries).doc('$id').delete();
  }

  Future<List<JournalEntryModel>> fetchAll() async {
    final snap = await col(FirebaseConstants.journalEntries).get();
    return snap.docs.map((d) => JournalEntryModel.fromMap(d.data())).toList();
  }
}
