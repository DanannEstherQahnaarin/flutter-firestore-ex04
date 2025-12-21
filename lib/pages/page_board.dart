import 'package:flutter/material.dart';
import 'package:flutter_firestore_ex04/common_widgets/common_dialog.dart';
import 'package:flutter_firestore_ex04/common_widgets/common_listview.dart';
import 'package:provider/provider.dart';
import 'package:flutter_firestore_ex04/provider/provider_board.dart';
import 'package:flutter_firestore_ex04/provider/provider_auth.dart';

class PostListPage extends StatelessWidget {
  const PostListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final boardProvider = context.watch<BoardProvider>();
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: '검색',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => boardProvider.updateSearchQuery(value),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: boardProvider.getPostStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                final posts = boardProvider.filteredPosts;

                return buildCommonListView(
                  items: posts,
                  itemBuilder: (context, index, item) => ListTile(
                    leading: item.isNotice
                        ? const Icon(Icons.campaign, color: Colors.red)
                        : (item.thumbnailUrl != null
                              ? Image.network(item.thumbnailUrl!, width: 50, fit: BoxFit.cover)
                              : const Icon(Icons.article, color: Colors.blue)),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        fontWeight: item.isNotice ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text('${item.writerNickname} | 조회수 ${item.viewCount}'),
                    onTap: () {
                      boardProvider.incrementViewCount(item.id);
                      //Navigator.pushNamed(context, '/postDetail', arguments: post);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: authProvider.isAdmin
          ? FloatingActionButton(
              onPressed: () => showCommonAlertDialog(
                context: context,
                title: '',
                content: '',
                onPositivePressed: () {},
              ),
            )
          : (authProvider.isAuthenticated
                ? FloatingActionButton(
                    onPressed: () => showCommonAlertDialog(
                      context: context,
                      title: '',
                      content: '',
                      onPositivePressed: () {},
                    ),
                  )
                : null),
    );
  }
}
