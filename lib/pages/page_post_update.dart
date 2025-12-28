import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_firestore_ex04/common_widgets/common_appbar.dart';
import 'package:flutter_firestore_ex04/common_widgets/common_dialog.dart';
import 'package:flutter_firestore_ex04/common_widgets/common_form_text.dart';
import 'package:flutter_firestore_ex04/models/model_post.dart';
import 'package:flutter_firestore_ex04/provider/provider_auth.dart';
import 'package:flutter_firestore_ex04/service/service_post.dart';
import 'package:flutter_firestore_ex04/service/service_validation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class PostUpdatePage extends StatefulWidget {
  final PostModel post;

  const PostUpdatePage({super.key, required this.post});

  @override
  State<PostUpdatePage> createState() => _PostUpdatePageState();
}

class _PostUpdatePageState extends State<PostUpdatePage> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController txtTitleController;
  late TextEditingController txtContentController;
  bool isAdminNotice = false;
  XFile? _selectedImage;
  Uint8List? _imageBytes;
  String? _thumbnailUrl;

  @override
  void initState() {
    super.initState();
    txtTitleController = TextEditingController(text: widget.post.title);
    txtContentController = TextEditingController(text: widget.post.content);
    isAdminNotice = widget.post.isNotice;
    _thumbnailUrl = widget.post.thumbnailUrl;
  }

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
      appBar: buildCommonAppBar(context, '게시글 수정'),
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
                  Text(
                    '작성일 : ${widget.post.createdAt.toString().substring(0, 19)} | 작성자 : ${widget.post.writerNickname}',
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
              ] else if (_thumbnailUrl != null) ...[
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
                    child: Image.network(_thumbnailUrl!, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _thumbnailUrl = null;
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
                      Navigator.of(context).pop();
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.cancel, color: Colors.red),
                        Text('Cancel', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      showCommonAlertDialog(
                        context: context,
                        title: 'Save',
                        content: '저장하시겠습니까?',
                        onPositivePressed: () async {
                          final result = await PostService().updatePost(
                            context: context,
                            post: PostModel(
                              id: widget.post.id,
                              title: txtTitleController.text,
                              content: txtContentController.text,
                              writerId: widget.post.writerId,
                              writerNickname: widget.post.writerNickname,
                              isNotice: isAdminNotice,
                              createdAt: widget.post.createdAt,
                              viewCount: widget.post.viewCount,
                              thumbnailUrl: _thumbnailUrl,
                            ),
                            formKey: formKey,
                            isAdminNotice: isAdminNotice,
                            selectedImage: _selectedImage,
                          );

                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(result.message),
                              backgroundColor: result.success ? Colors.green : Colors.red,
                            ),
                          );

                          if (result.success && mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                      );
                    },
                    child: const Row(children: [Icon(Icons.save), Text('Save')]),
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
