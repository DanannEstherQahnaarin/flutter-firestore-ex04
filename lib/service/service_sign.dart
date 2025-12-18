import 'package:flutter/material.dart';
import 'package:flutter_firestore_ex04/service/service_auth.dart';

class SignUp extends ChangeNotifier{

Future<bool> signUp({required String email, required String password, required String nickName}) async {
  final user = await AuthService().signUp(email: email, password: password, nickName: nickName);

  
}
}