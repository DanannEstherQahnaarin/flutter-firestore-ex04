import 'package:cloud_firestore/cloud_firestore.dart';

class ImagePostModel {
  final String id;
  final String imageUrl;
  final String description;
  final String writerId;
  final List<String> favorites;
  final DateTime createdAt;

  ImagePostModel({
    required this.id,
    required this.imageUrl,
    required this.description,
    required this.writerId,
    required this.favorites,
    required this.createdAt,
  });

  factory ImagePostModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ImagePostModel(
      id: doc.id,
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? '',
      writerId: data['writerId'] ?? '',
      favorites: List<String>.from(data['favorites'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
