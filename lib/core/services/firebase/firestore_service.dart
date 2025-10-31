// ignore_for_file: public_member_api_docs

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  const FirestoreService();

  FirebaseFirestore get instance => FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> col(String name) => instance.collection(name);
}
