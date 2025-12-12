import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final DatabaseReference _db = FirebaseDatabase.instance.ref();

  static Future<UserCredential> signUp({
    required String email,
    required String password,
    required String username,
    required String name,
    required int age,
    required String address,
    required String medicalHistory,
  }) async {
    UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    String uid = credential.user!.uid;

    await _db.child("users").child(uid).set({
      "uid": uid,
      "email": email,
      "username": username,
      "name": name,
      "age": age,
      "address": address,
      "medical_history": medicalHistory,
      "created_at": DateTime.now().toIso8601String(),
    });

    return credential;
  }

  static Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() => _auth.signOut();

  static User? get currentUser => _auth.currentUser;

  static Stream<User?> authStateChanges() => _auth.authStateChanges();

  static Future<DataSnapshot> getUserData() {
    final uid = _auth.currentUser!.uid;
    return _db.child("users").child(uid).get();
  }
}
