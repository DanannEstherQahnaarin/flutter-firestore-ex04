import 'package:flutter/material.dart';
import 'package:flutter_firestore_ex04/common_widgets/common_form_text.dart';
import 'package:flutter_firestore_ex04/service/service_sign.dart';
import 'package:flutter_firestore_ex04/service/service_validation.dart';

class ImageDetailDialog extends StatefulWidget {
  const ImageDetailDialog({super.key});

  @override
  State<ImageDetailDialog> createState() => _ImageDetailDialog();
}

class _ImageDetailDialog extends State<ImageDetailDialog> {
  final txtEmailEditingController = TextEditingController();
  final txtPasswordEditingController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    txtEmailEditingController.dispose();
    txtPasswordEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('로그인'),
    content: SingleChildScrollView(
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
          ],
        ),
      ),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('취소')),
      ElevatedButton(
        onPressed: () async {
          if (formKey.currentState?.validate() ?? false) {
            final result = await SignService().signIn(
              email: txtEmailEditingController.text,
              password: txtPasswordEditingController.text,
            );

            if (!context.mounted) return;

            if (result.success) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('로그인되었습니다.')));
            } else {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(result.message)));
            }
          }
        },
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [Icon(Icons.person_pin), SizedBox(width: 8), Text('로그인')],
        ),
      ),
    ],
  );
}
