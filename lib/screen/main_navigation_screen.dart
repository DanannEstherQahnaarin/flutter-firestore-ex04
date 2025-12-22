import 'package:flutter/material.dart';
import 'package:flutter_firestore_ex04/common_widgets/common_appbar.dart';
import 'package:flutter_firestore_ex04/common_widgets/common_navi.dart';
import 'package:flutter_firestore_ex04/pages/page_about.dart';
import 'package:flutter_firestore_ex04/pages/page_post_list.dart';
import 'package:flutter_firestore_ex04/pages/page_home.dart';
import 'package:flutter_firestore_ex04/pages/page_image_board.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  // 4개의 메뉴 페이지 정의
  final List<Widget> _widgetOptions = <Widget>[
    const HomePage(),
    const PostListPage(),
    const ImagePostListPage(),
    const AboutPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: buildCommonAppBar(context, 'Advanced Community'),
    body: Center(
      child: _widgetOptions.elementAt(_selectedIndex), // 선택된 페이지 표시
    ),
    bottomNavigationBar: buildCommonBottomNavigationBar(
      currentIndex: _selectedIndex,
      itemsMap: const {
        '홈': Icons.home,
        '글 게시판': Icons.article,
        '이미지 게시판': Icons.image,
        'About': Icons.info,
      },
      onTap: _onItemTapped,
    ),
  );
}
