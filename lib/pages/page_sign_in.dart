import 'package:flutter/material.dart';
import 'package:flutter_firestore_ex04/common_widgets/common_appbar.dart';
import 'package:flutter_firestore_ex04/common_widgets/common_form_text.dart';
import 'package:flutter_firestore_ex04/service/service_sign.dart';
import 'package:flutter_firestore_ex04/service/service_validation.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignPageState();
}

class _SignPageState extends State<SignInPage> {
  @override
  Widget build(BuildContext context) {
    final txtEmailEditingController = TextEditingController();
    final txtPasswordEditingController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    return Scaffold(
      appBar: buildCommonAppBar(context, 'Flutter Advanced Community'),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              commonFormText(
                controller: txtEmailEditingController,
                labelText: '이메일',
                keyboardType: TextInputType.emailAddress,
                validator: (value) => ValidationService.validateEmail(value: value ?? ''),
              ),
              const SizedBox(height: 15),
              commonFormText(
                controller: txtPasswordEditingController,
                labelText: '패스워드',
                obscureText: true,
                validator: (value) => ValidationService.validatePassword(value: value ?? ''),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState?.validate() ?? false) {
                    final result = await SignService().signIn(
                      email: txtEmailEditingController.text,
                      password: txtPasswordEditingController.text,
                    );

                    if (!context.mounted) return;

                    if (result.success) {
                      Navigator.pushReplacementNamed(context, '/');
                    } else {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(result.message)));
                    }
                  }
                },
                child: const Text('로그인'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/signUp');
                },
                child: const Text('계정이 없으신가요? 회원가입'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
