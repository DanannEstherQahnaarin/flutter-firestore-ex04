import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_firestore_ex04/common_widgets/common_form_text.dart';
import 'package:flutter_firestore_ex04/models/model_img_post.dart';
import 'package:flutter_firestore_ex04/provider/provider_auth.dart';
import 'package:flutter_firestore_ex04/provider/provider_img_board.dart';
import 'package:flutter_firestore_ex04/service/service_validation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ImageUpdateDialog extends StatefulWidget {
  final ImagePostModel imagePost;
  const ImageUpdateDialog({super.key, required this.imagePost});

  @override
  State<ImageUpdateDialog> createState() => _ImageUpdateDialogState();
}

class _ImageUpdateDialogState extends State<ImageUpdateDialog> {
  final formKey = GlobalKey<FormState>();
  final txtDescriptionController = TextEditingController();
  XFile? _selectedImage;
  Uint8List? _imageBytes;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    txtDescriptionController.text = widget.imagePost.description;
  }

  @override
  void dispose() {
    txtDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
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

  Future<void> _submit() async {
    if (!formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final imgProvider = context.read<ImageBoardProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await imgProvider.updateImagePost(
        postId: widget.imagePost.id,
        description: txtDescriptionController.text.trim(),
        imageFile: _selectedImage != null && !kIsWeb ? File(_selectedImage!.path) : null,
        imageBytes: _selectedImage != null && kIsWeb ? _imageBytes : null,
        userId: currentUser.uid,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('이미지 게시글이 수정되었습니다.')));

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('오류가 발생했습니다: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('이미지 수정'),
      content: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 설명 입력
              commonFormText(
                controller: txtDescriptionController,
                labelText: '설명',
                hintText: '이미지에 대한 설명을 입력하세요',
                validator: (value) =>
                    ValidationService.validateRequired(value: value ?? '', fieldName: '설명'),
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              // 이미지 선택/표시
              if (_selectedImage == null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.imagePost.imageUrl,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
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
              ],
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _showImageSourceDialog,
                icon: const Icon(Icons.add_photo_alternate),
                label: Text(_selectedImage != null ? '이미지 변경' : '이미지 변경'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('수정'),
        ),
      ],
    );
  }
}
