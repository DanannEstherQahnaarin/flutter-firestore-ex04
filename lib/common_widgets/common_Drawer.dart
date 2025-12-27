import 'package:flutter/material.dart';
import 'package:flutter_firestore_ex04/pages/page_about.dart';
import 'package:flutter_firestore_ex04/dialogs/dialog_sign_in.dart';
import 'package:flutter_firestore_ex04/dialogs/dialog_sign_up.dart';
import 'package:flutter_firestore_ex04/pages/page_user_list.dart';
import 'package:flutter_firestore_ex04/provider/provider_auth.dart';
import 'package:provider/provider.dart';

Widget buildDrawerMenu(BuildContext context) {
  final authProvider = context.watch<AuthProvider>();
  final isAuthenticated = authProvider.isAuthenticated;
  final isAdmin = authProvider.isAdmin;
  final currentUser = authProvider.currentUser;

  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        // Drawer 상단 헤더
        UserAccountsDrawerHeader(
          currentAccountPicture: const CircleAvatar(child: Icon(Icons.person)),
          accountName: Text(isAuthenticated ? (currentUser?.nickName ?? '사용자') : '비회원'),
          accountEmail: Text(isAuthenticated ? (currentUser?.email ?? '') : '로그인해주세요'),
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 39, 39, 39),
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10)),
          ),
        ),
        // 미로그인 시 메뉴
        if (!isAuthenticated) ...[
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text('회원가입'),
            onTap: () {
              Navigator.pop(context);
              showDialog(context: context, builder: (context) => const SignUpPage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.login),
            title: const Text('로그인'),
            onTap: () {
              Navigator.pop(context);
              showDialog(context: context, builder: (context) => const SignInPage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutPage()),
              );
            },
          ),
        ],
        // 로그인 시 메뉴 (일반 사용자)
        if (isAuthenticated && !isAdmin) ...[
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('로그아웃'),
            onTap: () {
              Navigator.pop(context);
              authProvider.signOut();
            },
          ),
        ],
        // 로그인 시 메뉴 (관리자)
        if (isAuthenticated && isAdmin) ...[
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('사용자 목록'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserListPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('로그아웃'),
            onTap: () {
              Navigator.pop(context);
              authProvider.signOut();
            },
          ),
        ],
      ],
    ),
  );
}
