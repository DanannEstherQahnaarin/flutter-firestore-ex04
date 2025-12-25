import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firestore_ex04/models/model_post.dart';

class BoardProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<PostModel> _posts = [];
  String _searchQuery = '';

  List<PostModel> get posts => _posts;

  Stream<List<PostModel>> getPostStream() => _db
      .collection('posts')
      .orderBy('isNotice', descending: true)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
        _posts = snapshot.docs.map((doc) => PostModel.fromDoc(doc)).toList();
        return _posts;
      });

  // 검색 쿼리 업데이트
  void updateSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners();
  }

  List<PostModel> get filteredPosts {
    if (_searchQuery.isEmpty) return _posts;

    return _posts.where((post) => post.title.toLowerCase().contains(_searchQuery)).toList();
  }

  Future<void> addPost(PostModel post) async {
    await _db.collection('posts').add({
      'title': post.title,
      'content': post.content,
      'writerId': post.writerId,
      'writerNickname': post.writerNickname,
      'thumbnailUrl': post.thumbnailUrl,
      'viewCount': 0,
      'isNotice': post.isNotice,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> incrementViewCount(String postId) async {
    await _db.collection('posts').doc(postId).update({'viewCount': FieldValue.increment(1)});
  }

  Future<void> updatePost(
    String postId, {
    required String title,
    required String content,
    String? thumbnailUrl,
    bool? isNotice,
  }) async {
    final Map<String, dynamic> updateData = {'title': title, 'content': content};

    if (thumbnailUrl != null) {
      updateData['thumbnailUrl'] = thumbnailUrl;
    }

    updateData['isNotice'] = isNotice ?? false;

    await _db.collection('posts').doc(postId).update(updateData);
  }
}
