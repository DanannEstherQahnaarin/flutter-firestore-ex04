import 'package:flutter/material.dart';
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
  void dispose() {
    txtEmailEditingController.dispose();
    txtPasswordEditingController.dispose();
    txtNickNameEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('회원가입'),
    content: SingleChildScrollView(
      child: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
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
          ],
        ),
      ),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('취소')),
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

                Navigator.of(context).pop(); // 확인 다이얼로그 닫기
                Navigator.of(context).pop(); // 회원가입 다이얼로그 닫기

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result.message),
                    backgroundColor: result.success ? Colors.green : Colors.red,
                  ),
                );
              },
            );
          }
        },
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [Icon(Icons.person_add), SizedBox(width: 8), Text('회원가입')],
        ),
      ),
    ],
  );
}
