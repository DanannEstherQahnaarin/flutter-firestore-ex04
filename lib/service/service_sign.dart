import 'package:flutter_firestore_ex04/service/service_auth.dart';

class SignService {
  Future<bool> signUp({
    required String email,
    required String password,
    required String nickName,
  }) async {
    final result = await AuthService().signUp(
      email: email,
      password: password,
      nickName: nickName,
    );

    return result == null ? true : false;
  }
}
