import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firestore_ex04/provider/provider_auth.dart';
import 'package:flutter_firestore_ex04/provider/provider_img_board.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

/// 이미지 게시판 관련 서비스 클래스
///
/// 이미지 게시글 목록 조회 및 관리 기능을 제공합니다.
class ImageService {
  Stream<QuerySnapshot<Map<String, dynamic>>> getImagePostList() =>
      ImageBoardProvider().getImagePostList();

  Future<({bool success, String message})> submit({
    required BuildContext context,
    XFile? selectedImage,
    Uint8List? imageBytes,
    required String description,
  }) async {
    final authProvider = context.read<AuthProvider>();
    final imgProvider = context.read<ImageBoardProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      return (success: false, message: '로그인이 필요합니다.');
    }

    try {
      // 추가 모드
      await imgProvider.uploadImagePost(
        imageFile: selectedImage != null && !kIsWeb ? File(selectedImage!.path) : null,
        imageBytes: selectedImage != null && kIsWeb ? imageBytes : null,
        description: description.trim(),
        userId: currentUser.uid,
      );

      return (success: true, message: '이미지 게시글이 추가되었습니다.');
    } catch (e) {
      return (success: false, message: '오류가 발생했습니다: ${e.toString()}');
    }
  }
}
