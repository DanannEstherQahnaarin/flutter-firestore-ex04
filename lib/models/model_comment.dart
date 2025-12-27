class CommentModel {
  final String id;
  final String postId;
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

  factory CommentModel.fromDoc(Map<String, dynamic> json) => CommentModel(
    id: json['id'] as String,
    postId: json['postId'] as String,
    writerId: json['writerId'] as String,
    writerNickname: json['writerNickname'] as String,
    content: json['content'] as String,
    createdAt: (json['createdAt'] is DateTime)
        ? json['createdAt'] as DateTime
        : DateTime.parse(json['createdAt'] as String),
  );

  Map<String, dynamic> toFirebase() => {
    'id': id,
    'postId': postId,
    'writerId': writerId,
    'writerNickname': writerNickname,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
  };
}
