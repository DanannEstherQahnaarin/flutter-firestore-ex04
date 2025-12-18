import 'package:flutter/material.dart';
import 'package:flutter_firestore_ex04/common_widgets/common_appbar.dart';
import 'package:flutter_firestore_ex04/common_widgets/common_dialog.dart';
import 'package:flutter_firestore_ex04/common_widgets/common_formText.dart';
import 'package:flutter_firestore_ex04/service/service_auth.dart';
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
    appBar: buildCommonAppBar('회원가입'),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            commonFormText(
              controller: txtNickNameEditingController,
              labelText: '닉네임',
              validator: (value) =>
                  ValidationService.validateRequired(value: value ?? '', fieldName: '닉네임'),
            ),
            commonFormText(
              controller: txtEmailEditingController,
              labelText: '이메일',
              keyboardType: TextInputType.emailAddress,
              validator: (value) => ValidationService.validateEmail(value: value ?? ''),
            ),
            commonFormText(
              controller: txtPasswordEditingController,
              labelText: '패스워드',
              obscureText: true,
              validator: (value) => ValidationService.validatePassword(value: value ?? ''),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
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

                    if (result) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('회원가입 되었습니다.')));
                    } else {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('회원가입입에 실패하였습니다.')));
                    }
                  },
                );
              },
              child: const Text('회원가입'),
            ),
          ],
        ),
      ),
    ),
  );
}
