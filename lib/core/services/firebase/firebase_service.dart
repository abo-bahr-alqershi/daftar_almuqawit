// ignore_for_file: public_member_api_docs

import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  Future<void> initialize() => Firebase.initializeApp();
}
