// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_firestore_ex04/common_widgets/common_sec_header.dart';
import 'package:flutter_firestore_ex04/models/model_img_post.dart';
import 'package:flutter_firestore_ex04/models/model_post.dart';
import 'package:flutter_firestore_ex04/provider/provider_auth.dart';
import 'package:flutter_firestore_ex04/provider/provider_home.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.read<HomeProvider>();
    final authProvider = context.watch<AuthProvider>();

    return SingleChildScrollView(
      child: Column(
        children: [
          // 1. 글 게시판 최신글 5개
          buildSectionHeader('📝 최근 게시글', () => /* 탭 이동 로직 */ {}),
          StreamBuilder(
            stream: homeProvider.getLatestPosts(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const LinearProgressIndicator();
              final posts = snapshot.data as List<PostModel>;
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: posts.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, i) => ListTile(
                  dense: true,
                  title: Text(posts[i].title),
                  trailing: Text(posts[i].writerNickname),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // 2. 이미지 게시판 최신 5개 (가로 스크롤)
          buildSectionHeader('📸 최신 이미지', () => {}),
          SizedBox(
            height: 150,
            child: StreamBuilder(
              stream: homeProvider.getLatestImages(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                final imgs = snapshot.data as List<ImagePostModel>;
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: imgs.length,
                  itemBuilder: (context, i) => Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(imgs[i].imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // 3. 내가 즐겨찾기한 이미지 (로그인 시에만)
          if (authProvider.isAuthenticated) ...[
            buildSectionHeader('⭐ 나의 즐겨찾기', () => {}),
            StreamBuilder(
              stream: homeProvider.getMyFavoriteImages(authProvider.currentUser!.uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('즐겨찾기한 이미지가 없습니다.'),
                  );
                }
                final favs = snapshot.data as List<ImagePostModel>;
                return SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: favs.length,
                    itemBuilder: (context, i) => CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(favs[i].imageUrl),
                      child: Container(margin: const EdgeInsets.only(right: 10)),
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
