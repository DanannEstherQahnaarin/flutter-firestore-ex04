import 'package:flutter/material.dart';

/// 공통 AppBar 위젯을 반환하는 함수.
///
/// [context] : BuildContext (위젯 트리의 context)
/// [title] : AppBar에 표시할 제목 텍스트
///
/// - AppBar 제목은 가운데 정렬됨.
/// - 배경색과 글자색, 그림자 높이 지정.
/// - 로그인 상태(isAuthenticated)에 따라 우측 action 아이콘이 변경됨.
///   - 로그인 상태면: 로그아웃 아이콘과 버튼 노출, 클릭 시 로그아웃 처리.
///   - 로그아웃 상태면: 로그인 아이콘과 버튼 노출, 클릭 시 '/login'으로 이동.
PreferredSizeWidget buildCommonAppBar(BuildContext context, String title) {
  // Provider를 통해 인증 상태(AuthProvider) 접근

  // 현재 route 확인
  final currentRoute = ModalRoute.of(context)?.settings.name;
  final isSignPage = currentRoute == '/signIn' || currentRoute == '/signUp';

  return AppBar(
    title: Text(title),
    automaticallyImplyLeading: !isSignPage,
    centerTitle: true, // 타이틀 중앙 정렬
    backgroundColor: const Color.fromARGB(255, 39, 39, 39), // AppBar 배경 색
    foregroundColor: const Color.fromARGB(139, 252, 229, 229), // AppBar 내 텍스트, 아이콘 색
    elevation: 2, // AppBar의 그림자 높이
  );
}
