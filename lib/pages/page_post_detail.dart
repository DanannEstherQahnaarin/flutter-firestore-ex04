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
      body: _isEditing ? _buildEditView(authProvider) : _buildDetailView(isEdit: canEdit),
    );
  }

  Widget _buildDetailView({bool isEdit = false}) => SingleChildScrollView(
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
        const SizedBox(height: 20),
        Row(
          children: [
            if (isEdit) ...[
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
                child: const Row(children: [Icon(Icons.edit), Text('Edit')]),
              ),
              ElevatedButton(
                onPressed: () {
                  // 원래 context를 저장 (dialog가 닫힌 후에도 사용하기 위해)
                  final navigatorContext = Navigator.of(context);

                  showCommonAlertDialog(
                    context: context,
                    title: 'Delete',
                    content: '삭제하시겠습니까?',
                    onPositivePressed: () async {
                      final result = await PostService().deletePost(
                        context: context,
                        postId: widget.post.id,
                      );

                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result.message),
                          backgroundColor: result.success ? Colors.green : Colors.red,
                        ),
                      );

                      // 삭제 성공 시 리스트 페이지로 돌아가기
                      if (result.success && mounted) {
                        // PostDetailPage를 닫아서 리스트 페이지로 돌아감
                        navigatorContext.pop();
                      }
                    },
                  );
                },
                child: const Row(children: [Icon(Icons.remove), Text('Delete')]),
              ),
            ] else
              const SizedBox.shrink(),
          ],
        ),
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
            children: [
              ElevatedButton(
                onPressed: () {
                  showCommonAlertDialog(
                    context: context,
                    title: 'Save',
                    content: '저장장하시겠습니까?',
                    onPositivePressed: () async {
                      final result = await PostService().updatePost(
                        context: context,
                        post: PostModel(
                          id: widget.post.id,
                          title: txtTitleController.text,
                          content: txtContentController.text,
                          writerId: widget.post.writerId,
                          writerNickname: widget.post.writerNickname,
                          viewCount: widget.post.viewCount,
                          isNotice: isAdminNotice,
                          createdAt: widget.post.createdAt,
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
                    },
                  );
                },
                child: const Row(children: [Icon(Icons.save), Text('Save')]),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isEditing = false;
                    // _buildEditView 초기화
                    txtTitleController.text = widget.post.title;
                    txtContentController.text = widget.post.content;
                    isAdminNotice = widget.post.isNotice;
                    _thumbnailUrl = widget.post.thumbnailUrl;
                    _selectedImage = null;
                    _imageBytes = null;
                  });
                },
                child: const Row(children: [Icon(Icons.cancel), Text('Cancel')]),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
