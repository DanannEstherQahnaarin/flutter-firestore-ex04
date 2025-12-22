/// [UserModel] 클래스는 사용자 정보를 관리하는 모델 클래스입니다.
///
/// - uid: 사용자의 고유 식별자
/// - nickName: 사용자의 닉네임
/// - email: 사용자의 이메일 주소
/// - role: 사용자의 권한/역할 (예: 'user', 'admin')
/// - createdAt: 계정 생성 일시
class UserModel {
  final String uid; // 사용자 고유 식별자
  final String nickName; // 사용자 닉네임
  final String email; // 사용자 이메일
  final String role; // 사용자 역할(권한)
  final DateTime createdAt; // 계정 생성 일시

  /// [UserModel] 생성자
  /// 모든 필드는 필수값입니다.
  UserModel({
    required this.uid,
    required this.nickName,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  /// Firestore에서 전달받은 user document를 UserModel 객체로 변환하는 팩토리 생성자입니다.
  ///
  /// [json]: Firestore 문서의 데이터(Map)
  /// - createdAt이 DateTime이면 그대로 사용
  /// - String 타입이면 DateTime.parse로 변환하여 사용
  factory UserModel.fromDoc(Map<String, dynamic> json) => UserModel(
    uid: json['uid'] as String,
    nickName: json['nickName'] as String,
    email: json['email'] as String,
    role: json['role'] as String,
    createdAt: (json['createdAt'] is DateTime)
        ? json['createdAt'] as DateTime
        : DateTime.parse(json['createdAt'] as String),
  );

  /// UserModel 객체를 Firestore에 저장할 수 있는 Map 형태로 변환합니다.
  ///
  /// createdAt은 ISO8601 문자열로 변환됩니다.
  Map<String, dynamic> toFirebase() => {
    'uid': uid,
    'nickName': nickName,
    'email': email,
    'role': role,
    'createdAt': createdAt.toIso8601String(),
  };
}
