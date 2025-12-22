import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_firestore_ex04/common_widgets/common_form_text.dart';
import 'package:flutter_firestore_ex04/provider/provider_auth.dart';
import 'package:flutter_firestore_ex04/service/service_validation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class PostAddPage extends StatefulWidget {
  const PostAddPage({super.key});

  @override
  State<PostAddPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostAddPage> {
  final formKey = GlobalKey<FormState>();
  final txtTitleController = TextEditingController();
  final txtContentController = TextEditingController();
  bool isAdminNotice = false;
  XFile? _selectedImage;

  @override
  void dispose() {
    txtTitleController.dispose();
    txtContentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('이미지 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('갤러리에서 선택'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('카메라로 촬영'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        child: Column(
          children: [
            commonFormText(
              controller: txtTitleController,
              labelText: 'Title',
              validator: (value) =>
                  ValidationService.validateRequired(value: value ?? '', fieldName: 'Title'),
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
            Row(
              children: [
                Text('작성일 : ${DateTime.now()} | 작성자 : ${authProvider.currentUser?.nickName}}'),
                authProvider.isAdmin
                    ? Checkbox(
                        value: isAdminNotice,
                        onChanged: (value) {
                          setState(() {
                            isAdminNotice = value ?? false;
                          });
                        },
                      )
                    : const SizedBox.shrink(),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
            commonFormText(
              controller: txtContentController,
              labelText: 'Content',
              maxLines: 10, // 게시판 본문 작성용, 넉넉하게 10줄로 설정
              validator: (value) =>
                  ValidationService.validateRequired(value: value ?? '', fieldName: 'Content'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.label_important),
                const Text('thumbnail'),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: _showImageSourceDialog,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('이미지 선택'),
                ),
              ],
            ),
            if (_selectedImage != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(File(_selectedImage!.path), fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedImage = null;
                      });
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('이미지 제거', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
