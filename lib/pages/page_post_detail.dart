import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_firestore_ex04/common_widgets/common_appbar.dart';
import 'package:flutter_firestore_ex04/common_widgets/common_form_text.dart';
import 'package:flutter_firestore_ex04/models/model_post.dart';
import 'package:flutter_firestore_ex04/provider/provider_auth.dart';
import 'package:flutter_firestore_ex04/service/service_validation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class PostDetailPage extends StatefulWidget {
  final PostModel post;

  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  bool _isEditing = false;
  final formKey = GlobalKey<FormState>();
  late TextEditingController txtTitleController;
  late TextEditingController txtContentController;
  bool isAdminNotice = false;
  XFile? _selectedImage;
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

  bool _canEdit() {
    final authProvider = context.read<AuthProvider>();
    return authProvider.isAdmin ||
        (authProvider.isAuthenticated &&
            authProvider.currentUser?.uid == widget.post.writerId);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final canEdit = _canEdit();

    return Scaffold(
      appBar: buildCommonAppBar(context, _isEditing ? '게시글 수정' : '게시글 상세'),
      body: _isEditing ? _buildEditView(authProvider) : _buildDetailView(),
    );
  }

  Widget _buildDetailView() => SingleChildScrollView(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.post.isNotice)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              '공지',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        const SizedBox(height: 8),
        Text(
          widget.post.title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              '작성자: ${widget.post.writerNickname}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(width: 16),
            Text('조회수: ${widget.post.viewCount}', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '작성일: ${widget.post.createdAt.toString().substring(0, 19)}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const Divider(height: 32),
        if (widget.post.thumbnailUrl != null) ...[
          Image.network(widget.post.thumbnailUrl!, width: double.infinity, fit: BoxFit.cover),
          const SizedBox(height: 16),
        ],
        Text(widget.post.content, style: const TextStyle(fontSize: 16)),
      ],
    ),
  );

  Widget _buildEditView(AuthProvider authProvider) => Form(
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
        ],
      ),
    ),
  );
}
