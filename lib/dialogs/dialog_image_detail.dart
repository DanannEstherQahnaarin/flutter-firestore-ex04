import 'package:flutter/material.dart';
import 'package:flutter_firestore_ex04/models/model_img_post.dart';
import 'package:flutter_firestore_ex04/provider/provider_auth.dart';
import 'package:flutter_firestore_ex04/provider/provider_img_board.dart';
import 'package:flutter_firestore_ex04/dialogs/dialog_image_update.dart';
import 'package:provider/provider.dart';

class ImageDetailDialog extends StatelessWidget {
  final ImagePostModel image;
  const ImageDetailDialog({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final imgProvider = context.read<ImageBoardProvider>();
    final currentUserId = authProvider.currentUser?.uid;
    final isFavorite = currentUserId != null && image.favorites.contains(currentUserId);
    final canEdit = currentUserId != null && currentUserId == image.writerId;

    return AlertDialog(
      title: const Text('이미지 상세'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 표시
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: double.infinity,
                height: 300,
                child: Image.network(
                  image.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.error, size: 50, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 설명 표시
            Text(
              '설명',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(image.description, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            // 좋아요 수 표시
            Row(
              children: [
                Icon(Icons.favorite, color: Colors.red, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${image.favorites.length}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        // 좋아요 토글 버튼
        if (currentUserId != null)
          IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.red),
            onPressed: () {
              imgProvider.toggleFavorite(image.id, currentUserId);
            },
            tooltip: isFavorite ? '좋아요 취소' : '좋아요',
          ),
        // 수정 버튼 (작성자만 표시)
        if (canEdit)
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop(); // 현재 다이얼로그 닫기
              showDialog(
                context: context,
                builder: (context) => ImageUpdateDialog(imagePost: image),
              );
            },
            icon: const Icon(Icons.edit),
            label: const Text('수정'),
          ),
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('닫기')),
      ],
    );
  }
}
