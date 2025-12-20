import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String title;
  final String content;
  final String writerId;
  final String writerNickname;
  final String? thumbnailUrl;
  final int viewCount;
  final bool isNotice;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.title,
    required this.content,
    required this.writerId,
    required this.writerNickname,
    this.thumbnailUrl,
    required this.viewCount,
    required this.isNotice,
    required this.createdAt,
  });

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
