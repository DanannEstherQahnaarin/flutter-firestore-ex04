import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firestore_ex04/firebase_options.dart';
import 'package:flutter_firestore_ex04/pages/page_about.dart';
import 'package:flutter_firestore_ex04/pages/page_board_list.dart';
import 'package:flutter_firestore_ex04/pages/page_image_board_list.dart';
import 'package:flutter_firestore_ex04/screen/main_navigation_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_firestore_ex04/provider/provider_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Flutter Advanced Community',
    theme: ThemeData(primarySwatch: Colors.blue),
    // 초기 페이지는 홈페이지로 설정
    initialRoute: '/',
    routes: {
      '/': (context) => const MainNavigationScreen(),
      '/board': (context) => const BoardListPage(),
      '/imageBoard': (context) => const ImageBoardListPage(),
      '/about': (context) => const AboutPage(),
      // TODO: 로그인, 회원가입 라우트 추가 예정
    },
  );
}
