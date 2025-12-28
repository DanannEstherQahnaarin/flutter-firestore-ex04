import 'package:cloud_firestore/cloud_firestore.dart';

/// [PostModel] 클래스는 게시글 정보를 담는 데이터 모델입니다.
///
/// - id: 게시글의 고유 식별자 (document id)
/// - title: 게시글의 제목
/// - content: 게시글의 본문
/// - writerId: 작성자의 고유 식별자(uid)
/// - writerNickname: 작성자 닉네임
/// - thumbnailUrl: 썸네일 이미지 URL (null 가능)
/// - viewCount: 게시글 조회수
/// - isNotice: 공지 여부(true면 공지사항)
/// - createdAt: 글 작성 일시
class PostModel {
  /// 게시글의 고유 식별자 (Firestore document id)
  final String id;

  /// 게시글 제목
  final String title;

  /// 게시글 본문 내용
  final String content;

  /// 작성자 uid
  final String writerId;

  /// 작성자 닉네임
  final String writerNickname;

  /// 게시글 썸네일 URL (없을 수 있음)
  final String? thumbnailUrl;

  /// 조회수
  final int? viewCount;

  /// 공지사항 여부
  final bool isNotice;

  /// 작성 일시
  final DateTime createdAt;

  /// [PostModel] 생성자
  ///
  /// 모든 필수 필드를 받아 게시글 모델을 생성한다.
  PostModel({
    required this.id,
    required this.title,
    required this.content,
    required this.writerId,
    required this.writerNickname,
    this.thumbnailUrl,
    this.viewCount,
    required this.isNotice,
    required this.createdAt,
  });

  /// Firestore DocumentSnapshot에서 PostModel 객체 생성 팩토리 생성자
  ///
  /// - [doc]: Firestore 문서 스냅샷
  /// - 각 필드는 Map에서 값을 꺼내서 저장됨
  /// - createdAt은 Timestamp를 DateTime으로 변환하여 사용
  factory PostModel.fromDoc(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return PostModel(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      writerId: data['writerId'] ?? '',
      writerNickname: data['writerNickname'] ?? '',
      thumbnailUrl: data['thumbnailUrl'],
      viewCount: data['viewCount'] ?? 0,
      isNotice: data['isNotice'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
