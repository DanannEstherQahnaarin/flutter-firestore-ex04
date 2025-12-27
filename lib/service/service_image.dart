import 'package:cloud_firestore/cloud_firestore.dart';

/// 이미지 게시판 관련 서비스 클래스
///
/// 이미지 게시글 목록 조회 및 관리 기능을 제공합니다.
class ImageService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String collection = 'imagePosts';

  /// 이미지 게시글 목록을 Stream으로 반환합니다.
  ///
  /// 작성일 기준 내림차순으로 정렬된 이미지 게시글 목록을 실시간으로 제공합니다.
  ///
  /// 반환값:
  /// - Stream<QuerySnapshot>: Firestore 쿼리 스냅샷 스트림
  Stream<QuerySnapshot<Map<String, dynamic>>> getImagePostList() =>
      _db.collection(collection).orderBy('createdAt', descending: true).snapshots();
}
