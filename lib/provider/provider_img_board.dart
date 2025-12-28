// lib/providers/image_board_provider.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firestore_ex04/service/service_file.dart';

class ImageBoardProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 이미지 업로드 및 게시물 생성
  Future<void> uploadImagePost({
    File? imageFile,
    Uint8List? imageBytes,
    required String description,
    required String userId,
    String? fileName,
  }) async {
    // 1. Storage에 이미지 업로드 (새로운 경로 규칙 사용)
    final fileService = FileCtlService();
    final String fName = fileName ?? DateTime.now().millisecondsSinceEpoch.toString();

    final uploadResult = await fileService.fileUpload(
      uid: userId,
      folder: 'images',
      file: imageFile,
      bytes: imageBytes,
      fileName: fName,
    );

    if (!uploadResult.success) {
      throw Exception('이미지 업로드 실패: ${uploadResult.url}');
    }

    final String downloadUrl = uploadResult.url;

    // 2. Firestore에 정보 저장
    await _db.collection('imagePosts').add({
      'imageUrl': downloadUrl,
      'description': description,
      'writerId': userId,
      'favorites': [],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 이미지 게시글 수정
  Future<void> updateImagePost({
    required String postId,
    required String description,
    File? imageFile,
    Uint8List? imageBytes,
    required String userId,
    String? fileName,
  }) async {
    String? finalImageUrl;

    // 새 이미지가 선택된 경우에만 업로드
    if (imageFile != null || imageBytes != null) {
      final fileService = FileCtlService();
      final String fName = fileName ?? DateTime.now().millisecondsSinceEpoch.toString();

      final uploadResult = await fileService.fileUpload(
        uid: userId,
        folder: 'images',
        file: imageFile,
        bytes: imageBytes,
        fileName: fName,
      );

      if (!uploadResult.success) {
        throw Exception('이미지 업로드 실패: ${uploadResult.url}');
      }

      finalImageUrl = uploadResult.url;
    }

    // Firestore 업데이트
    final updateData = <String, dynamic>{'description': description};

    // 새 이미지가 있으면 imageUrl도 업데이트
    if (finalImageUrl != null) {
      updateData['imageUrl'] = finalImageUrl;
    }

    await _db.collection('imagePosts').doc(postId).update(updateData);
  }

  // 즐겨찾기 토글 (U: Update)
  Future<void> toggleFavorite(String postId, String userId) async {
    final DocumentReference docRef = _db.collection('imagePosts').doc(postId);
    final DocumentSnapshot doc = await docRef.get();
    final List<String> favorites = List<String>.from(doc['favorites'] ?? []);

    if (favorites.contains(userId)) {
      favorites.remove(userId);
    } else {
      favorites.add(userId);
    }
    await docRef.update({'favorites': favorites});
  }
}
