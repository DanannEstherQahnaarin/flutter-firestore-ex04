import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firestore_ex04/models/model_post.dart';
import 'package:flutter_firestore_ex04/service/service_cloud_functions.dart';

class BoardProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final collection = 'post_collection';
  List<PostModel> _posts = [];
  String _searchQuery = '';

  List<PostModel> get posts => _posts;

  Stream<List<PostModel>> getPostStream() => _db
      .collection(collection)
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
    await _db.collection(collection).add({
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

  /// Cloud Functions를 사용하여 조회수를 안전하게 증가시킵니다.
  ///
  /// 클라이언트에서 직접 수정하는 대신 서버 측에서 처리하여
  /// 보안과 데이터 무결성을 보장합니다.
  Future<void> incrementViewCount(String postId) async {
    try {
      final cloudFunctionsService = CloudFunctionsService();
      final result = await cloudFunctionsService.incrementViewCount(postId);

      if (result.success) {
        // 성공 시 로컬 상태 업데이트 (선택적)
        // Stream이 자동으로 업데이트되므로 notifyListeners는 필요 없을 수 있음
        notifyListeners();
      } else {
        // 실패 시 로그만 남기고 계속 진행
        debugPrint('조회수 증가 실패: ${result.message}');
      }
    } catch (e) {
      // Cloud Functions 호출 실패 시 기존 방식으로 폴백 (선택적)
      debugPrint('Cloud Functions 호출 실패, 폴백: $e');
      try {
        await _db.collection(collection).doc(postId).update({
          'viewCount': FieldValue.increment(1),
        });
        notifyListeners();
      } catch (fallbackError) {
        debugPrint('폴백 조회수 증가도 실패: $fallbackError');
      }
    }
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

    await _db.collection(collection).doc(postId).update(updateData);
  }

  Future<PostModel?> getPost(String postId) async {
    try {
      final doc = await _db.collection(collection).doc(postId).get();
      if (doc.exists) {
        return PostModel.fromDoc(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> deletePost(String postId) async {
    await _db.collection(collection).doc(postId).delete();
  }
}
