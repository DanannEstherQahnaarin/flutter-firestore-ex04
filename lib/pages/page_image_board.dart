import 'package:flutter/material.dart';
import 'package:flutter_firestore_ex04/dialogs/dialog_image_add.dart';
import 'package:flutter_firestore_ex04/dialogs/dialog_image_detail.dart';
import 'package:flutter_firestore_ex04/models/model_img_post.dart';
import 'package:flutter_firestore_ex04/provider/provider_auth.dart';
import 'package:flutter_firestore_ex04/provider/provider_img_board.dart';
import 'package:flutter_firestore_ex04/service/service_image.dart';
import 'package:provider/provider.dart';

class ImagePostListPage extends StatefulWidget {
  const ImagePostListPage({super.key});

  @override
  State<ImagePostListPage> createState() => _ImagePostListPageState();
}

class _ImagePostListPageState extends State<ImagePostListPage> {
  @override
  Widget build(BuildContext context) {
    final imgProvider = context.read<ImageBoardProvider>();
    final authProvider = context.watch<AuthProvider>();
    final imageService = ImageService();

    return Scaffold(
      body: StreamBuilder(
        stream: imageService.getImagePostList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No Images'));
          }

          final docs = snapshot.data!.docs;

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              try {
                final post = ImagePostModel.fromDoc(docs[index]);
                final isFav = post.favorites.contains(authProvider.currentUser?.uid);

                return InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => ImageDetailDialog(image: post),
                    );
                  },
                  child: Card(
                    child: Column(
                      children: [
                        Expanded(child: Image.network(post.imageUrl, fit: BoxFit.cover)),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  post.description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  final userId = authProvider.currentUser?.uid;
                                  if (userId != null) {
                                    imgProvider.toggleFavorite(post.id, userId);
                                  }
                                },
                                child: Icon(
                                  isFav ? Icons.favorite : Icons.favorite_border,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } catch (e) {
                // 데이터 파싱 오류 발생 시 빈 카드 반환
                return Card(child: Center(child: Text('데이터 로딩 오류: ${e.toString()}')));
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            showDialog(context: context, builder: (context) => const ImageAddDialog()),
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}
