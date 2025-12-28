import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_firestore_ex04/common_widgets/common_dialog.dart';
import 'package:flutter_firestore_ex04/common_widgets/common_form_text.dart';
import 'package:flutter_firestore_ex04/service/service_image.dart';
import 'package:flutter_firestore_ex04/service/service_validation.dart';
import 'package:image_picker/image_picker.dart';

class ImageAddDialog extends StatefulWidget {
  const ImageAddDialog({super.key});

  @override
  State<ImageAddDialog> createState() => _ImageAddDialogState();
}

class _ImageAddDialogState extends State<ImageAddDialog> {
  final formKey = GlobalKey<FormState>();
  final txtDescriptionController = TextEditingController();
  XFile? _selectedImage;
  Uint8List? _imageBytes;
  bool _isLoading = false;

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
    showImageSourceDialog(
      context: context,
      onImageSourceSelected: (ImageSource source) {
        _pickImage(source);
      },
    );
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('이미지 추가'),
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
              label: Text(_selectedImage != null ? '이미지 변경' : '이미지 선택'),
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
        onPressed: _isLoading
            ? null
            : () async {
                // 폼 검증
                if (!formKey.currentState!.validate()) return;

                // 이미지 선택 확인
                if (_selectedImage == null) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('이미지를 선택해주세요.')));
                  return;
                }

                setState(() => _isLoading = true);

                final result = await ImageService().submit(
                  context: context,
                  description: txtDescriptionController.text,
                  imageBytes: _imageBytes,
                  selectedImage: _selectedImage,
                );

                if (!mounted) return;

                setState(() => _isLoading = false);

                // 결과 메시지 표시
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result.message),
                    backgroundColor: result.success ? Colors.green : Colors.red,
                  ),
                );

                // 성공 시 다이얼로그 닫기
                if (result.success) {
                  Navigator.of(context).pop();
                }
              },
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('추가'),
      ),
    ],
  );
}
