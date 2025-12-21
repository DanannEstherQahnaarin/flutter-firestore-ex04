class CommentModel {
  final String id;
  final String postId; // 게시글 ID (일반/이미지 공용)
  final String writerId;
  final String writerNickname;
  final String content;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.postId,
    required this.writerId,
    required this.writerNickname,
    required this.content,
    required this.createdAt,
  });
}
