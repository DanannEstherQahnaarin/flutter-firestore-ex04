import 'package:flutter/material.dart';

/// BottomNavigationBar를 생성하는 공통 함수
///
/// [itemsMap] - 라벨(String)과 아이콘(IconData)의 맵 (최소 1개 이상의 항목 필요)
/// [currentIndex] - 현재 선택된 인덱스
/// [onTap] - 아이템 선택 시 호출될 콜백 함수
Widget buildCommonBottomNavigationBar({
  required Map<String, IconData> itemsMap,
  required int currentIndex,
  required ValueChanged<int> onTap,
}) {
  // 최소 1개 이상의 아이템이 있어야 함
  assert(itemsMap.isNotEmpty, 'itemsMap은 최소 1개 이상의 항목이 있어야 합니다.');

  // 맵의 entries를 순회하여 BottomNavigationBarItem 리스트 생성
  final List<BottomNavigationBarItem> items = itemsMap.entries
      .map((entry) => BottomNavigationBarItem(icon: Icon(entry.value), label: entry.key))
      .toList();

  return BottomNavigationBar(
    currentIndex: currentIndex,
    selectedItemColor: Colors.blue,
    unselectedItemColor: Colors.amber,
    onTap: onTap,
    items: items,
    type: BottomNavigationBarType.fixed,
  );
}
