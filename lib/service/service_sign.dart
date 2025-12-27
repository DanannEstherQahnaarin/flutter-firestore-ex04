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
    try {
      final User? result = await AuthService().signIn(email: email, password: password);

      if (result != null) {
        return (success: true, user: result, message: '로그인되었습니다.');
      } else {
        return (success: false, user: null, message: '로그인에 실패하였습니다.');
      }
    } on FirebaseAuthException catch (e) {
      // AuthService에서 변환된 사용자 친화적인 메시지 사용
      return (success: false, user: null, message: e.message ?? '로그인에 실패하였습니다.');
    } catch (e) {
      return (success: false, user: null, message: '로그인 중 오류가 발생했습니다: ${e.toString()}');
    }
  }
}
