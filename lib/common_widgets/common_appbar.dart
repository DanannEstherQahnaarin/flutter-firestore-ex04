import 'package:flutter/material.dart';

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
