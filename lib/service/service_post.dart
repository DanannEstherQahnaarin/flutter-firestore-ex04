import 'package:flutter/material.dart';
import 'package:flutter_firestore_ex04/models/model_post.dart';
import 'package:flutter_firestore_ex04/provider/provider_auth.dart';
import 'package:flutter_firestore_ex04/provider/provider_board.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class PostService {
  Future<({bool success, String message})> addPost({
    required BuildContext context,
    required String title,
    required String contents,
    XFile? selectedImage,
    required GlobalKey<FormState> formKey,
    required bool isAdminNotice,
  }) async {
    final boardProvider = context.read<BoardProvider>();
    final authProvider = context.read<AuthProvider>();

    try {
      String? finalThumbnailUrl = null;

      if (selectedImage != null) {
        // 이미지 업로드 로직이 필요하면 여기에 구현
        // finalThumbnailUrl = await uploadImage(_selectedImage!);
      }

      final currentUser = authProvider.currentUser;
      if (currentUser == null) {
        return (success: false, message: '로그인이 필요합니다.');
      }

      final now = DateTime.now();
      final post = PostModel(
        id: '', // 임시 id, addPost에서 무시됨
        title: title,
        content: contents,
        writerId: currentUser.uid,
        writerNickname: currentUser.nickName,
        thumbnailUrl: finalThumbnailUrl,
        viewCount: 0,
        isNotice: authProvider.isAdmin ? isAdminNotice : false,
        createdAt: now,
      );

      await boardProvider.addPost(post);

      return (success: false, message: '게시글이 작성되었습니다.');
    } catch (e) {
      return (success: false, message: '작성 중 오류가 발생했습니다: $e');
    }
  }
}
