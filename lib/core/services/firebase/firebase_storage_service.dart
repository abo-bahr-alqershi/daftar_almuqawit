// ignore_for_file: public_member_api_docs

import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  FirebaseStorage get instance => _storage;
}
