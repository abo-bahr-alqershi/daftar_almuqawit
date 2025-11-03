// ignore_for_file: public_member_api_docs

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/firebase/firestore_service.dart';

/// أساس لمصادر البيانات البعيدة (Firestore)
abstract class BaseRemoteDataSource {
  final FirestoreService fs;
  const BaseRemoteDataSource(this.fs);

  FirebaseFirestore get _db => fs.firestore;

  CollectionReference<Map<String, dynamic>> col(String name) => _db.collection(name);
}
