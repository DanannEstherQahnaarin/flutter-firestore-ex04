// lib/providers/image_board_provider.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firestore_ex04/service/service_file.dart';

class ImageBoardProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String collection = 'image_collection';

  /// 이미지 게시글 목록을 Stream으로 반환합니다.
  ///
  /// 작성일 기준 내림차순으로 정렬된 이미지 게시글 목록을 실시간으로 제공합니다.
  ///
  /// 반환값:
  /// - Stream<QuerySnapshot>: Firestore 쿼리 스냅샷 스트림
  Stream<QuerySnapshot<Map<String, dynamic>>> getImagePostList() =>
      _db.collection(collection).orderBy('createdAt', descending: true).snapshots();

  /// 이미지를 Firebase Storage에 업로드하는 내부 메서드
  ///
  /// [userId] : 사용자 ID
  /// [imageFile] : 업로드할 이미지 파일 (모바일 플랫폼)
  /// [imageBytes] : 업로드할 이미지 바이트 데이터 (웹 플랫폼)
  /// [fileName] : 파일명 (선택사항, 기본값: 타임스탬프)
  ///
  /// 반환값: 업로드된 이미지의 다운로드 URL
  /// 예외: 업로드 실패 시 Exception 발생
  Future<String> _uploadImage({
    required String userId,
    File? imageFile,
    Uint8List? imageBytes,
    String? fileName,
  }) async {
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

    return uploadResult.url;
  }

  // 이미지 업로드 및 게시물 생성
  Future<void> uploadImagePost({
    File? imageFile,
    Uint8List? imageBytes,
    required String description,
    required String userId,
    String? fileName,
  }) async {
    // 1. Storage에 이미지 업로드
    final downloadUrl = await _uploadImage(
      userId: userId,
      imageFile: imageFile,
      imageBytes: imageBytes,
      fileName: fileName,
    );

    // 2. Firestore에 정보 저장
    await _db.collection(collection).add({
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
      finalImageUrl = await _uploadImage(
        userId: userId,
        imageFile: imageFile,
        imageBytes: imageBytes,
        fileName: fileName,
      );
    }

    // Firestore 업데이트
    final updateData = <String, dynamic>{'description': description};

    // 새 이미지가 있으면 imageUrl도 업데이트
    if (finalImageUrl != null) {
      updateData['imageUrl'] = finalImageUrl;
    }

    await _db.collection(collection).doc(postId).update(updateData);
  }

  // 즐겨찾기 토글 (U: Update)
  Future<void> toggleFavorite(String postId, String userId) async {
    final DocumentReference docRef = _db.collection(collection).doc(postId);
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
