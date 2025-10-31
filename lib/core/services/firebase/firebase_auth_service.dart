// ignore_for_file: public_member_api_docs

import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get onAuthStateChanged => _auth.authStateChanges();

  Future<UserCredential> signInAnonymously() => _auth.signInAnonymously();
  Future<void> signOut() => _auth.signOut();
}
