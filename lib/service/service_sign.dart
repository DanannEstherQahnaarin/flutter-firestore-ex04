import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_firestore_ex04/service/service_auth.dart';

class SignService {
  Future<({bool success, String message})> signUp({
    required String email,
    required String password,
    required String nickName,
  }) async {
    final result = await AuthService().signUp(
      email: email,
      password: password,
      nickName: nickName,
    );

    return result == null
        ? (success: true, message: '회원가입 되었습니다.')
        : (success: false, message: result);
  }

  Future<({bool success, User? user, String message})> signIn({
    required String email,
    required String password,
  }) async {
    final User? result = await AuthService().signIn(email: email, password: password);

    if (result != null) {
      return (success: true, user: result, message: '');
    } else {
      return (success: false, user: null, message: '로그인에 실패하였습니다');
    }
  }
}
