import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_firestore_ex04/models/model_user.dart';

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String userCollection = 'user_collection';

  User? get currentUser => firebaseAuth.currentUser;

  Future<String?> signUp({
    required String email,
    required String password,
    required String nickName,
  }) async {
    try {
      final UserCredential result = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = result.user;

      await _db.collection(userCollection).doc(user!.uid).set({});

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Stream<List<UserModel>> getUsers() => _db
      .collection(userCollection)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs.map((doc) => UserModel.fromFirebase(doc.data())).toList(),
      );

  Future<void> updateUserRole(String uid, String newRole) async {
    await _db.collection(userCollection).doc(uid).update({'role': newRole});
  }

  Future<void> deleteUser(String uid) async {
    await _db.collection('users').doc(uid).delete();
  }
}
