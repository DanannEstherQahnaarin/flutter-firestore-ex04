class ValidationService {
  // 1. 이메일 형식 검증
  static String? validateEmail({required String value}) {
    if (value.isEmpty) {
      return '이메일을 입력해 주세요.';
    }
    // 간단한 이메일 정규식 패턴
    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegExp.hasMatch(value)) {
      return '유효한 이메일 형식이 아닙니다.';
    }
    return null; // 유효함
  }

  // 2. 비밀번호 길이 검증
  static String? validatePassword({required String value}) {
    if (value.isEmpty) {
      return '비밀번호를 입력해 주세요.';
    }
    if (value.length < 6) {
      return '비밀번호는 최소 6자 이상이어야 합니다.';
    }
    return null;
  }

  // 3. 필수 입력값 검증 (범용)
  static String? validateRequired({required String value, required String fieldName}) {
    if (value.trim().isEmpty) {
      return '$fieldName을(를) 입력해 주세요.';
    }
    return null;
  }
}
