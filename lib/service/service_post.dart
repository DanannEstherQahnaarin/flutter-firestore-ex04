import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_firestore_ex04/models/model_post.dart';
import 'package:flutter_firestore_ex04/provider/provider_auth.dart';
import 'package:flutter_firestore_ex04/provider/provider_board.dart';
import 'package:flutter_firestore_ex04/service/service_file.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class PostService {
  Future<({bool success, String message})> addPost({
    required BuildContext context,
    required String title,
    required String contents,
    XFile? selectedImage,
    required bool isAdminNotice,
  }) async {
    final boardProvider = context.read<BoardProvider>();
    final authProvider = context.read<AuthProvider>();

    try {
      String? finalThumbnailUrl;

      if (selectedImage != null) {
        final fileService = FileCtlService();
        final file = File(selectedImage.path);
        final uploadResult = await fileService.fileUpload(
          file: file,
          fileName: '${DateTime.now().millisecondsSinceEpoch}_${selectedImage.name}',
        );

        if (uploadResult.success) {
          finalThumbnailUrl = uploadResult.url;
        } else {
          return (success: false, message: '이미지 업로드 실패: ${uploadResult.url}');
        }
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

      return (success: true, message: '게시글이 작성되었습니다.');
    } catch (e) {
      return (success: false, message: '작성 중 오류가 발생했습니다: $e');
    }
  }

  Future<({bool success, String message})> updatePost({
    required BuildContext context,
    required PostModel post,
    XFile? selectedImage,
    required GlobalKey<FormState> formKey,
    required bool isAdminNotice,
  }) async {
    final boardProvider = context.read<BoardProvider>();
    final authProvider = context.read<AuthProvider>();
    String? finalThumbnailUrl = post.thumbnailUrl;

    try {
      if (selectedImage != null) {
        final fileService = FileCtlService();
        final file = File(selectedImage.path);
        final uploadResult = await fileService.fileUpload(
          file: file,
          fileName: '${DateTime.now().millisecondsSinceEpoch}_${selectedImage.name}',
        );

        if (uploadResult.success) {
          finalThumbnailUrl = uploadResult.url;
        } else {
          return (success: false, message: '이미지 업로드 실패: ${uploadResult.url}');
        }
      }

      await boardProvider.updatePost(
        post.id,
        title: post.title,
        content: post.content,
        thumbnailUrl: finalThumbnailUrl,
        isNotice: authProvider.isAdmin ? isAdminNotice : null,
      );

      return (success: true, message: '수정되었습니다.');
    } catch (e) {
      return (success: false, message: '수정 중 오류가 발생했습니다: $e');
    }
  }

  Future<({bool success, String message})> deletePost({
    required BuildContext context,
    required String postId,
  }) async {
    final boardProvider = context.read<BoardProvider>();

    try {
      // 게시글 정보 가져오기 (썸네일 URL 확인용)
      final post = await boardProvider.getPost(postId);

      if (post == null) {
        return (success: false, message: '게시글을 찾을 수 없습니다.');
      }

      // 썸네일이 있으면 Firebase Storage에서 삭제
      if (post.thumbnailUrl != null && post.thumbnailUrl!.isNotEmpty) {
        final fileService = FileCtlService();
        final deleteResult = await fileService.fileDelete(downloadURL: post.thumbnailUrl!);

        // 썸네일 삭제 실패해도 게시글은 삭제 진행 (경고만 표시)
        if (!deleteResult.success) {
          // 썸네일 삭제 실패는 로그만 남기고 계속 진행
          debugPrint('썸네일 삭제 실패: ${deleteResult.message}');
        }
      }

      // Firestore에서 게시글 삭제
      await boardProvider.deletePost(postId);

      return (success: true, message: '게시글이 삭제되었습니다.');
    } catch (e) {
      return (success: false, message: '삭제 중 오류가 발생했습니다: $e');
    }
  }
}
