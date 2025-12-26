import 'package:flutter/material.dart';
import 'package:flutter_firestore_ex04/common_widgets/common_appbar.dart';
import 'package:flutter_firestore_ex04/common_widgets/common_dialog.dart';
import 'package:flutter_firestore_ex04/common_widgets/common_form_text.dart';
import 'package:flutter_firestore_ex04/service/service_sign.dart';
import 'package:flutter_firestore_ex04/service/service_validation.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final txtEmailEditingController = TextEditingController();
  final txtPasswordEditingController = TextEditingController();
  final txtNickNameEditingController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: buildCommonAppBar(context, 'Flutter Advanced Community'),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: ' Member Sign Up ',
              labelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                fontStyle: FontStyle.italic,
              ),
              border: OutlineInputBorder(), // 외곽선 디자인
              contentPadding: EdgeInsets.only(
                bottom: 10,
                top: 50,
                left: 15,
                right: 15,
              ), // 내부 여백
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                commonFormText(
                  controller: txtNickNameEditingController,
                  labelText: '닉네임',
                  prefixIcon: const Icon(Icons.person),
                  validator: (value) =>
                      ValidationService.validateRequired(value: value ?? '', fieldName: '닉네임'),
                ),
                const SizedBox(height: 15),
                commonFormText(
                  controller: txtEmailEditingController,
                  labelText: '이메일',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email),
                  validator: (value) => ValidationService.validateEmail(value: value ?? ''),
                ),
                const SizedBox(height: 15),
                commonFormText(
                  controller: txtPasswordEditingController,
                  labelText: '패스워드',
                  obscureText: true,
                  prefixIcon: const Icon(Icons.password),
                  validator: (value) => ValidationService.validatePassword(value: value ?? ''),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      showCommonAlertDialog(
                        context: context,
                        title: '회원가입',
                        content: '회원가입을 진행하시겠습니까?',
                        onPositivePressed: () async {
                          final result = await SignService().signUp(
                            email: txtEmailEditingController.text,
                            password: txtPasswordEditingController.text,
                            nickName: txtNickNameEditingController.text,
                          );

                          if (!context.mounted) return;

                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(result.message)));
                        },
                      );
                    }
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [Icon(Icons.person_add), SizedBox(width: 8), Text('회원가입')],
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/signIn');
                  },
                  child: const Text('이미 계정이 있으신가요? 로그인'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
