import 'package:flutter/material.dart';
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
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final post = ImagePostModel.fromDoc(docs[index]);
              final isFav = post.favorites.contains(authProvider.currentUser?.uid);

              return Card(
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
                          IconButton(
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              final userId = authProvider.currentUser?.uid;
                              if (userId != null) {
                                imgProvider.toggleFavorite(post.id, userId);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pickAndUploadImage(context),
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }

  void _pickAndUploadImage(BuildContext context) {
    // ImagePicker로 사진 선택 후 Provider의 uploadImagePost 호출 로직 구현
  }
}
