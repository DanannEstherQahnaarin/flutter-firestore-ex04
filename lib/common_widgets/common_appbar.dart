import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_firestore_ex04/provider/provider_auth.dart';

/// [context] - BuildContext
/// [title] - AppBar에 표시할 타이틀
PreferredSizeWidget buildCommonAppBar(BuildContext context, String title) {
  final authProvider = context.watch<AuthProvider>();

  return AppBar(
    title: Text(title),
    centerTitle: true,
    backgroundColor: const Color.fromARGB(255, 39, 39, 39),
    foregroundColor: const Color.fromARGB(139, 252, 229, 229),
    elevation: 2,
    actions: [
      if (authProvider.isAuthenticated)
        IconButton(onPressed: () => authProvider.signOut(), icon: const Icon(Icons.logout))
      else
        IconButton(
          onPressed: () => Navigator.pushNamed(context, '/login'),
          icon: const Icon(Icons.login),
        ),
    ],
  );
}
