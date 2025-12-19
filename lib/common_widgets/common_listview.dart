import 'package:flutter/material.dart';

/// 재사용 가능한 ListView.builder를 생성하는 함수
///
/// [items] - 표시할 데이터 리스트
/// [itemBuilder] - 각 항목을 빌드하는 콜백 함수 (필수)
/// [emptyWidget] - 데이터가 없을 때 표시할 위젯 (기본값: 'No DATA' 텍스트)
/// [scrollDirection] - 스크롤 방향 (기본값: Axis.vertical)
/// [shrinkWrap] - shrinkWrap 속성 (기본값: false)
/// [padding] - 리스트 패딩
///
/// 사용 예시:
/// ```dart
/// buildCommonListView<UserModel>(
///   items: users,
///   itemBuilder: (context, index, user) {
///     return ListTile(
///       title: Text(user.nickName),
///     );
///   },
/// )
/// ```
Widget buildCommonListView<T>({
  required List<T> items,
  required Widget Function(BuildContext context, int index, T item) itemBuilder,
  Widget? emptyWidget,
  Axis scrollDirection = Axis.vertical,
  bool shrinkWrap = false,
  EdgeInsetsGeometry? padding,
}) {
  if (items.isEmpty) {
    return emptyWidget ?? const Center(child: Text('No DATA'));
  }

  return ListView.builder(
    itemCount: items.length,
    itemBuilder: (context, index) => itemBuilder(context, index, items[index]),
    scrollDirection: scrollDirection,
    shrinkWrap: shrinkWrap,
    padding: padding,
  );
}
