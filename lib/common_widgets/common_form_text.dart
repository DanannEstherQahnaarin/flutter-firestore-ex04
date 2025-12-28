import 'package:flutter/material.dart';

/// 공통 폼 텍스트 입력 필드 위젯 생성 함수.
///
/// - 다양한 폼(로그인, 회원가입, 정보수정 등)에서 재사용을 위한 TextFormField 생성 함수.
/// - 입력값 제어를 위한 [controller]는 필수.
/// - 라벨(제목) 텍스트 [labelText] 필수, 힌트 [hintText], 비밀번호 노출/숨김 [obscureText] 지정 가능.
/// - 유효성 검사 함수 [validator], 입력 키보드 타입 [keyboardType], 활성화/비활성화 [enabled] 지원.
/// - 한 줄/여러 줄 [maxLines], 앞/뒤 아이콘 [prefixIcon]/[suffixIcon] 옵션 지정 가능.
/// - 커스텀 데코레이션 [decoration] 전달 시 적용, 미전달 시 기본 스타일 사용(아웃라인박스+여백 등)
///
/// 기본 데코레이션:
///   - 레이블텍스트, 힌트, 앞/뒤 아이콘 반영
///   - OutlineInputBorder와 넉넉한 내부 여백(horizontal: 16, vertical: 16)
///
/// 예시:
/// ```dart
/// commonFormText(
///   controller: myController,
///   labelText: '이메일',
///   hintText: '이메일을 입력하세요',
///   keyboardType: TextInputType.emailAddress,
///   validator: (value) => value!.isEmpty ? '필수 입력' : null,
///   prefixIcon: Icon(Icons.email),
/// )
/// ```
TextFormField commonFormText({
  required TextEditingController controller,
  required String labelText,
  String hintText = '',
  bool obscureText = false,
  String? Function(String?)? validator,
  TextInputType keyboardType = TextInputType.text,
  bool enabled = true,
  int maxLines = 1,
  Widget? prefixIcon,
  Widget? suffixIcon,
  InputDecoration? decoration,
}) => TextFormField(
  controller: controller,
  obscureText: obscureText,
  validator: validator,
  keyboardType: maxLines > 1 ? TextInputType.multiline : keyboardType,
  textInputAction: maxLines > 1 ? TextInputAction.newline : TextInputAction.done,
  enabled: enabled,
  maxLines: maxLines,
  decoration:
      decoration ??
      InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
);
