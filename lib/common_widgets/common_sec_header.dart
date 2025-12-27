import 'dart:ui';

import 'package:flutter/material.dart';

Widget buildSectionHeader(String title, VoidCallback onTap) => Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      TextButton(onPressed: onTap, child: const Text('더보기')),
    ],
  ),
);
