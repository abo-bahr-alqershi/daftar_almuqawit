// ignore_for_file: public_member_api_docs

import '../../../core/constants/firebase_constants.dart';
import '../../../core/services/firebase/firestore_service.dart';
import '../../models/journal_entry_detail_model.dart';
import 'base_remote_datasource.dart';

class JournalEntryDetailsRemoteDataSource extends BaseRemoteDataSource {
  JournalEntryDetailsRemoteDataSource(FirestoreService fs) : super(fs);

  Future<void> upsert(JournalEntryDetailModel model) async {
    await col(FirebaseConstants.journalEntryDetails).doc('${model.id}').set(model.toMap());
  }

  Future<void> delete(int id) async {
    await col(FirebaseConstants.journalEntryDetails).doc('$id').delete();
  }

  Future<List<JournalEntryDetailModel>> fetchByEntry(int entryId) async {
    final snap = await col(FirebaseConstants.journalEntryDetails).where('entry_id', isEqualTo: entryId).get();
    return snap.docs.map((d) => JournalEntryDetailModel.fromMap(d.data())).toList();
  }
}
