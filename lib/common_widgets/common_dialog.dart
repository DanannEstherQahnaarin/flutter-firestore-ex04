import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// 공통 AlertDialog(알림/확인 대화상자) 표시 함수
///
/// [context] : 다이얼로그를 표시할 BuildContext
/// [title] : 다이얼로그의 제목
/// [content] : 다이얼로그의 내용 메시지
/// [positiveButtonText] : '확인'(또는 '예') 버튼 텍스트 (기본값: 'OK')
/// [negativeButtonText] : '취소'(또는 '아니오') 버튼 텍스트 (기본값: 'Cancel')
/// [onPositivePressed] : '확인'(또는 '예') 버튼 클릭 시 호출할 콜백 함수 (nullable)
/// [onNegativePressed] : '취소'(또는 '아니오') 버튼 클릭 시 호출할 콜백 함수 (nullable)
///
/// - AlertDialog는 기본 타이틀, 본문, 2개의 액션 버튼으로 구성됨.
/// - '취소/아니오' 버튼 클릭 시 다이얼로그를 닫고, onNegativePressed 콜백(있으면) 실행.
/// - '확인/예' 버튼 클릭 시 다이얼로그를 닫고, onPositivePressed 콜백(있으면) 실행.
/// - 버튼 텍스트를 지정하지 않으면 기본값 사용.
///
/// 사용 예시:
/// ```dart
/// showCommonAlertDialog(
///   context: context,
///   title: '경고',
///   content: '삭제하시겠습니까?',
///   onPositivePressed: () { /* 삭제 처리 */ },
/// );
/// ```
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
        // 취소/아니오 버튼: Dialog를 닫고 onNegativePressed 콜백 실행(있으면)
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Dialog 닫기
            onNegativePressed?.call(); // 콜백 함수 실행 (있는 경우)
          },
          child: Text(negativeButtonText),
        ),
        // 확인/예 버튼: Dialog를 닫고 onPositivePressed 콜백 실행(있으면)
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

/// 공통 이미지 선택 다이얼로그 표시 함수
///
/// [context] : 다이얼로그를 표시할 BuildContext
/// [onImageSourceSelected] : 이미지 소스(갤러리 또는 카메라) 선택 시 호출할 콜백 함수
///
/// - 사용자에게 갤러리에서 선택 또는 카메라로 촬영 옵션을 제공
/// - 선택된 ImageSource를 콜백 함수로 전달
///
/// 사용 예시:
/// ```dart
/// showImageSourceDialog(
///   context: context,
///   onImageSourceSelected: (ImageSource source) {
///     _pickImage(source);
///   },
/// );
/// ```
void showImageSourceDialog({
  required BuildContext context,
  required Function(ImageSource source) onImageSourceSelected,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: const Text('이미지 선택'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('갤러리에서 선택'),
            onTap: () {
              Navigator.pop(context);
              onImageSourceSelected(ImageSource.gallery);
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('카메라로 촬영'),
            onTap: () {
              Navigator.pop(context);
              onImageSourceSelected(ImageSource.camera);
            },
          ),
        ],
      ),
    ),
  );
}
