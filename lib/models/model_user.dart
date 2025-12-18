class User {
  final String uid;
  final String nickName;
  final String email;
  final String role;
  final DateTime createdAt;

  User({
    required this.uid,
    required this.nickName,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  factory User.fromFirebase(Map<String, dynamic> json) => User(
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
