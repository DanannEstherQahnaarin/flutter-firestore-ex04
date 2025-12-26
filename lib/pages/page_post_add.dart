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
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('게시글 작성'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 39, 39, 39),
        foregroundColor: const Color.fromARGB(139, 252, 229, 229),
        elevation: 2,
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  Expanded(
                    child: Text(
                      '작성일 : ${DateTime.now().toString().substring(0, 19)} | 작성자 : ${authProvider.currentUser?.nickName ?? '익명'}',
                    ),
                  ),
                  if (authProvider.isAdmin)
                    Checkbox(
                      value: isAdminNotice,
                      onChanged: (value) {
                        setState(() {
                          isAdminNotice = value ?? false;
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),
              commonFormText(
                controller: txtContentController,
                labelText: 'Content',
                maxLines: 10, // 게시판 본문 작성용, 넉넉하게 10줄로 설정
                validator: (value) => ValidationService.validateRequired(
                  value: value ?? '',
                  fieldName: 'Content',
                ),
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
              const SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (!formKey.currentState!.validate()) {
                        return;
                      }
                    },
                    child: const Row(
                      children: [Icon(Icons.add), SizedBox(width: 10), Text('Add')],
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Row(
                      children: [Icon(Icons.add), SizedBox(width: 10), Text('Cancel')],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
