import 'package:flutter/material.dart';

/// 모든 페이지에서 공통으로 사용 가능한 AppBar를 반환하는 함수
///
/// [title] - AppBar에 표시할 타이틀
PreferredSizeWidget buildCommonAppBar(String title) => AppBar(
  title: Text(title),
  centerTitle: true,
  elevation: 2,
  actions: [
    IconButton(onPressed: () {}, icon: const Icon(Icons.home)),
    IconButton(onPressed: () {}, icon: const Icon(Icons.login)),
  ],
);
