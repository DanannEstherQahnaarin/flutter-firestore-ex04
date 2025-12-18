import 'package:flutter/material.dart';

/// AlertDialog를 표시하는 공통 함수
///
/// [context] - BuildContext
/// [title] - Dialog 제목
/// [content] - Dialog 내용
/// [positiveButtonText] - 확인/예 버튼 텍스트 (예: "OK", "Yes")
/// [negativeButtonText] - 취소/아니오 버튼 텍스트 (예: "Cancel", "No")
/// [onPositivePressed] - 확인/예 버튼 클릭 시 호출될 콜백 함수 (nullable)
/// [onNegativePressed] - 취소/아니오 버튼 클릭 시 호출될 콜백 함수 (nullable)
void showCommonAlertDialog({
  required BuildContext context,
  required String title,
  required String content,
  String positiveButtonText = 'OK',
  String negativeButtonText = 'Cancel',
  VoidCallback? onPositivePressed,
  VoidCallback? onNegativePressed,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        // 취소/아니오 버튼
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Dialog 닫기
            onNegativePressed?.call(); // 콜백 함수 실행 (있는 경우)
          },
          child: Text(negativeButtonText),
        ),
        // 확인/예 버튼
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Dialog 닫기
            onPositivePressed?.call(); // 콜백 함수 실행 (있는 경우)
          },
          child: Text(positiveButtonText),
        ),
      ],
    ),
  );
}
