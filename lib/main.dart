import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter_firestore_ex04/firebase_options.dart';
import 'package:flutter_firestore_ex04/pages/page_about.dart';
import 'package:flutter_firestore_ex04/pages/page_post_add.dart';
import 'package:flutter_firestore_ex04/pages/page_post_list.dart';
import 'package:flutter_firestore_ex04/pages/page_image_board.dart';
import 'package:flutter_firestore_ex04/provider/provider_board.dart';
import 'package:flutter_firestore_ex04/provider/provider_home.dart';
import 'package:flutter_firestore_ex04/provider/provider_img_board.dart';
import 'package:flutter_firestore_ex04/screen/main_navigation_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_firestore_ex04/provider/provider_auth.dart';
import 'package:flutter_firestore_ex04/provider/provider_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 플랫폼별로 Firebase App Check 활성화
  if (kIsWeb) {
    // Web 플랫폼은 App Check 지원 안 함 (선택적)
    // await FirebaseAppCheck.instance.activate(
    //   webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    // );
  } else if (defaultTargetPlatform == TargetPlatform.android) {
    // Android 플랫폼
    await FirebaseAppCheck.instance.activate(
      androidProvider: kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
    );
  } else if (defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    // iOS/macOS 플랫폼
    await FirebaseAppCheck.instance.activate(
      appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.deviceCheck,
    );
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BoardProvider()),
        ChangeNotifierProvider(create: (_) => ImageBoardProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
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
      // 초기 페이지는 홈으로 설정 (인증 없이 접근 가능)
      initialRoute: '/',
      routes: {'/': (context) => const MainNavigationScreen()},
      onGenerateRoute: (settings) {
        // 홈 페이지는 인증 없이 접근 가능
        if (settings.name == '/') {
          return null; // routes에서 처리
        }

        // 다른 페이지들 - Builder를 사용하여 Provider에 접근
        return MaterialPageRoute(
          builder: (routeContext) {
            final authProvider = Provider.of<AuthProvider>(routeContext, listen: false);

            // 로딩 중이면 대기 화면 표시
            if (authProvider.isLoading) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            // 인증이 필요한 페이지들
            switch (settings.name) {
              case '/board':
                return const PostListPage();
              case '/post-add':
                return const PostAddPage();
              case '/imageBoard':
                return const ImagePostListPage();
              case '/about':
                return const AboutPage();
              default:
                return const MainNavigationScreen();
            }
          },
        );
      },
    ),
  );
}
