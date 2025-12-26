// lib/providers/image_board_provider.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ImageBoardProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // 이미지 업로드 및 게시물 생성
  Future<void> uploadImagePost(File imageFile, String description, String userId) async {
    // 1. Storage에 이미지 업로드
    final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final Reference ref = _storage.ref().child('posts/$fileName');
    final UploadTask uploadTask = ref.putFile(imageFile);
    final TaskSnapshot snapshot = await uploadTask;
    final String downloadUrl = await snapshot.ref.getDownloadURL();

    // 2. Firestore에 정보 저장
    await _db.collection('imagePosts').add({
      'imageUrl': downloadUrl,
      'description': description,
      'writerId': userId,
      'favorites': [],
      'createdAt': FieldValue.serverTimestamp(),
    });
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
