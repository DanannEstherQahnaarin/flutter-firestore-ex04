import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firestore_ex04/firebase_options.dart';
import 'package:flutter_firestore_ex04/pages/page_about.dart';
import 'package:flutter_firestore_ex04/pages/page_post_add.dart';
import 'package:flutter_firestore_ex04/pages/page_post_list.dart';
import 'package:flutter_firestore_ex04/pages/page_image_board.dart';
import 'package:flutter_firestore_ex04/pages/page_sign_in.dart';
import 'package:flutter_firestore_ex04/pages/page_sign_up.dart';
import 'package:flutter_firestore_ex04/provider/provider_board.dart';
import 'package:flutter_firestore_ex04/screen/main_navigation_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_firestore_ex04/provider/provider_auth.dart';
import 'package:flutter_firestore_ex04/provider/provider_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BoardProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => Consumer<ThemeProvider>(
    builder: (context, themeProvider, child) => MaterialApp(
      title: 'Flutter Advanced Community',
      theme: ThemeProvider.lightTheme,
      darkTheme: ThemeProvider.darkTheme,
      themeMode: themeProvider.themeMode,
      // 초기 페이지는 로그인페이지로 설정
      initialRoute: '/signIn',
      routes: {
        '/signIn': (context) => const SignInPage(),
        '/signUp': (context) => const SignUpPage(),
      },
      onGenerateRoute: (settings) {
        // 회원가입과 로그인 페이지는 인증 없이 접근 가능
        if (settings.name == '/signIn' || settings.name == '/signUp') {
          return null; // routes에서 처리
        }

        // 인증이 필요한 페이지들 - Builder를 사용하여 Provider에 접근
        return MaterialPageRoute(
          builder: (routeContext) {
            final authProvider = Provider.of<AuthProvider>(routeContext, listen: false);

            // 로딩 중이면 대기 화면 표시
            if (authProvider.isLoading) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            // 인증되지 않은 경우 로그인 페이지로 리다이렉트
            if (!authProvider.isAuthenticated) {
              return const SignInPage();
            }

            // 인증된 경우 요청한 페이지로 이동
            switch (settings.name) {
              case '/':
                return const MainNavigationScreen();
              case '/board':
                return const PostListPage();
              case '/post-add':
                return const PostAddPage();
              case '/imageBoard':
                return const ImagePostListPage();
              case '/about':
                return const AboutPage();
              default:
                return const SignInPage();
            }
          },
        );
      },
    ),
  );
}
