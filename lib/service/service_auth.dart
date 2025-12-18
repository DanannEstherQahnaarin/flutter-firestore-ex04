import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => firebaseAuth.currentUser;

  Future<String?> signUp({
    required String email,
    required String password,
    required String nickName,
  }) async {
    final UserCredential result = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final User? user = result.user;

    await _db.collection('user_collection').doc(user!.uid).set({});

    return null;
  }
}
