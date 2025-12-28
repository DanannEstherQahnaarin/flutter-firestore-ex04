import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_firestore_ex04/common_widgets/common_dialog.dart';
import 'package:flutter_firestore_ex04/common_widgets/common_form_text.dart';
import 'package:flutter_firestore_ex04/provider/provider_auth.dart';
import 'package:flutter_firestore_ex04/service/service_post.dart';
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
  Uint8List? _imageBytes;

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
      // 웹 플랫폼에서는 바이트 데이터를 읽어서 저장
      Uint8List? bytes;
      if (kIsWeb) {
        bytes = await image.readAsBytes();
      }

      setState(() {
        _selectedImage = image;
        _imageBytes = bytes;
      });
    }
  }

  void _showImageSourceDialog() {
    showImageSourceDialog(
      context: context,
      onImageSourceSelected: (ImageSource source) {
        _pickImage(source);
      },
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
                maxLines: 10,
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
                    child: kIsWeb
                        ? _imageBytes != null
                              ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                              : const Center(child: CircularProgressIndicator())
                        : Image.file(File(_selectedImage!.path), fit: BoxFit.cover),
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
                          _imageBytes = null;
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
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.cancel, color: Colors.red),
                        SizedBox(width: 10),
                        Text('Cancel', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) {
                        return;
                      }

                      // 로딩 표시
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(child: CircularProgressIndicator()),
                      );

                      final postService = PostService();
                      final result = await postService.addPost(
                        context: context,
                        title: txtTitleController.text.trim(),
                        contents: txtContentController.text.trim(),
                        selectedImage: _selectedImage,
                        isAdminNotice: isAdminNotice,
                      );

                      // 로딩 닫기
                      if (context.mounted) {
                        Navigator.pop(context);
                      }

                      // 결과 메시지 표시
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result.message),
                            backgroundColor: result.success ? Colors.green : Colors.red,
                          ),
                        );

                        // 성공 시 페이지 닫기
                        if (result.success) {
                          Navigator.pop(context);
                        }
                      }
                    },
                    child: const Row(
                      children: [Icon(Icons.edit), SizedBox(width: 10), Text('Write')],
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
