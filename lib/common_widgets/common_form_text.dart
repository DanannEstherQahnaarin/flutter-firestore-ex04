import 'package:flutter/material.dart';

/// [controller] - 텍스트 입력을 제어하는 TextEditingController (필수)
/// [labelText] - 레이블 텍스트
/// [hintText] - 힌트 텍스트
/// [obscureText] - 비밀번호 입력 여부 (기본값: false)
/// [validator] - 입력값 검증 함수
/// [keyboardType] - 키보드 타입
/// [textInputAction] - 키보드 액션 버튼 타입
/// [enabled] - 필드 활성화 여부 (기본값: true)
/// [maxLines] - 최대 라인 수 (기본값: 1)
/// [prefixIcon] - 앞쪽 아이콘
/// [suffixIcon] - 뒤쪽 아이콘
/// [decoration] - 커스텀 decoration (다른 decoration 파라미터보다 우선순위 높음)
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
  keyboardType: keyboardType,
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
