import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String authorId;
  final String authorName;
  final double price;
  final String category;
  final List<String> colors;
  final String description;
  final String imageUrl;
  final String medium;
  final String size;
  final int yearCreated;
  final List<String> tags;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.authorId,
    required this.authorName,
    required this.price,
    required this.category,
    required this.colors,
    required this.description,
    required this.imageUrl,
    required this.medium,
    required this.size,
    required this.yearCreated,
    required this.tags,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'authorId': authorId,
      'authorName': authorName,
      'price': price,
      'category': category,
      'colors': colors,
      'description': description,
      'imageUrl': imageUrl,
      'medium': medium,
      'size': size,
      'yearCreated': yearCreated,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static Product fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      authorId: map['authorId'],
      authorName: map['authorName'],
      price: map['price'],
      category: map['category'],
      colors: List<String>.from(map['colors']),
      description: map['description'],
      imageUrl: map['imageUrl'] ?? '',
      medium: map['medium'],
      size: map['size'],
      yearCreated: map['yearCreated'],
      tags: List<String>.from(map['tags']),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
