class UserModel {
  final String uid;
  final String nickName;
  final String email;
  final String role;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.nickName,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  factory UserModel.fromFirebase(Map<String, dynamic> json) => UserModel(
    uid: json['uid'] as String,
    nickName: json['nickName'] as String,
    email: json['email'] as String,
    role: json['role'] as String,
    createdAt: (json['createdAt'] is DateTime)
        ? json['createdAt'] as DateTime
        : DateTime.parse(json['createdAt'] as String),
  );

  Map<String, dynamic> toFirebase() => {
    'uid': uid,
    'nickName': nickName,
    'email': email,
    'role': role,
    'createdAt': createdAt.toIso8601String(),
  };
}
