import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firestore_ex04/models/model_user.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String userCollection = 'user_collection';

  UserModel? _userModel;
  bool _isLoading = true;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _auth.currentUser != null;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) async {
      if (user == null) {
        _userModel = null;
      } else {
        await _fetchUserData(user.uid);
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> _fetchUserData(String uid) async {
    final DocumentSnapshot doc = await _db.collection(userCollection).doc(uid).get();

    if (doc.exists) {
      _userModel = UserModel.fromDoc(doc.data() as Map<String, dynamic>);
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _userModel = null;
    notifyListeners();
  }

  bool get isAdmin => _userModel?.role == 'admin';

  /// 현재 로그인된 사용자의 정보를 반환합니다.
  /// 로그인되어 있지 않으면 null을 반환합니다.
  UserModel? get currentUser => _userModel;
}
