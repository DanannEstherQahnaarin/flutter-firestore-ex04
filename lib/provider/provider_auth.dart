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
    } on FirebaseAuthException catch (e) {
      // Firebase Auth 예외를 사용자 친화적인 메시지로 변환
      String errorMessage;
      switch (e.code) {
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          errorMessage = '이메일 또는 비밀번호가 올바르지 않습니다.';
          break;
        case 'invalid-email':
          errorMessage = '올바른 이메일 형식이 아닙니다.';
          break;
        case 'user-disabled':
          errorMessage = '이 계정은 비활성화되었습니다.';
          break;
        case 'too-many-requests':
          errorMessage = '너무 많은 로그인 시도가 있었습니다. 잠시 후 다시 시도해주세요.';
          break;
        case 'network-request-failed':
          errorMessage = '네트워크 연결을 확인해주세요.';
          break;
        default:
          errorMessage = '로그인에 실패했습니다. ${e.message ?? e.code}';
      }
      return errorMessage;
    } catch (e) {
      return '로그인 중 오류가 발생했습니다: ${e.toString()}';
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
