import 'package:cloud_firestore/cloud_firestore.dart';
/// [ImagePostModel] 클래스는 이미지 게시판의 게시글 데이터를 관리하는 모델 클래스입니다.
///
/// - id: 게시글의 고유 ID(Firestore 문서 ID)
/// - imageUrl: 게시된 이미지의 URL
/// - description: 게시글의 설명(본문)
/// - writerId: 게시글 작성자(사용자)의 uid
/// - favorites: 해당 게시글을 '좋아요'한 사용자 uid 목록
/// - createdAt: 게시글 작성 일시(DateTime)
///
/// 주요 기능:
/// - Firestore document 데이터를 [ImagePostModel] 객체로 변환하는 factory 생성자([fromDoc])
/// - (필요 시) Firestore 업로드용 Map 변환 등의 확장 가능

class ImagePostModel {
  final String id;
  final String imageUrl;
  final String description;
  final String writerId;
  final List<String> favorites;
  final DateTime createdAt;

  ImagePostModel({
    required this.id,
    required this.imageUrl,
    required this.description,
    required this.writerId,
    required this.favorites,
    required this.createdAt,
  });

  factory ImagePostModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ImagePostModel(
      id: doc.id,
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? '',
      writerId: data['writerId'] ?? '',
      favorites: List<String>.from(data['favorites'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
