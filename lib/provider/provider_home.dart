// lib/providers/home_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firestore_ex04/models/model_img_post.dart';
import 'package:flutter_firestore_ex04/models/model_post.dart';

class HomeProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final postCollection = 'post_collection';
  final imageCollection = 'image_collection';

  // 글 게시판 최신글 5개 스트림
  Stream<List<PostModel>> getLatestPosts() => _db
      .collection(postCollection)
      .orderBy('createdAt', descending: true)
      .limit(5)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => PostModel.fromDoc(doc)).toList());

  // 이미지 게시판 최신글 5개 스트림
  Stream<List<ImagePostModel>> getLatestImages() => _db
      .collection(imageCollection)
      .orderBy('createdAt', descending: true)
      .limit(5)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => ImagePostModel.fromDoc(doc)).toList());

  // 내가 즐겨찾기한 이미지 스트림
  Stream<List<ImagePostModel>> getMyFavoriteImages(String userId) => _db
      .collection(imageCollection)
      .where('favorites', arrayContains: userId)
      .limit(5)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => ImagePostModel.fromDoc(doc)).toList());
}
