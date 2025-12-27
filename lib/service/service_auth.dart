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

      await _db
          .collection(userCollection)
          .doc(user!.uid)
          .set(
            UserModel(
              uid: user.uid,
              nickName: nickName,
              email: email,
              role: 'user',
              createdAt: DateTime.now(),
            ).toFirebase(),
          );

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// 로그인을 시도합니다.
  ///
  /// [email] 사용자 이메일
  /// [password] 사용자 비밀번호
  ///
  /// 반환값:
  /// - 성공 시: User 객체
  /// - 실패 시: null (오류 메시지는 throw되지 않음)
  ///
  /// 예외:
  /// - FirebaseAuthException: 인증 실패 시 사용자 친화적인 메시지와 함께 throw
  Future<User?> signIn({required String email, required String password}) async {
    try {
      final UserCredential result = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
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
      throw FirebaseAuthException(code: e.code, message: errorMessage);
    } catch (e) {
      // 기타 예외 처리
      if (e is FirebaseAuthException) {
        rethrow;
      }
      throw FirebaseAuthException(
        code: 'unknown-error',
        message: '로그인 중 오류가 발생했습니다: ${e.toString()}',
      );
    }
  }

  Stream<List<UserModel>> getUsers() => _db
      .collection(userCollection)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => UserModel.fromDoc(doc.data())).toList());

  Future<void> updateUserRole(String uid, String newRole) async {
    await _db.collection(userCollection).doc(uid).update({'role': newRole});
  }

  Future<void> deleteUser(String uid) async {
    await _db.collection(userCollection).doc(uid).delete();
  }
}
