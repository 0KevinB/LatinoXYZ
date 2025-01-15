import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String userId;
  final String username;
  final String text;
  final DateTime createdAt;
  final List<Comment> comments;
  final List<String> likes;
  final String? mediaUrl;

  PostModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.text,
    required this.createdAt,
    required this.comments,
    required this.likes,
    this.mediaUrl,
  });

  factory PostModel.fromMap(Map<String, dynamic> map, String id) {
    return PostModel(
      id: id,
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      text: map['caption'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      comments: (map['comments'] as List<dynamic>? ?? [])
          .map((comment) => Comment.fromMap(comment as Map<String, dynamic>))
          .toList(),
      likes: List<String>.from(map['likes'] ?? []),
      mediaUrl: map['mediaUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'caption': text,
      'createdAt': Timestamp.fromDate(createdAt),
      'comments': comments.map((comment) => comment.toMap()).toList(),
      'likes': likes,
      'mediaUrl': mediaUrl,
    };
  }
}

class Comment {
  final String userId;
  final String username;
  final String text;
  final DateTime createdAt;

  Comment({
    required this.userId,
    required this.username,
    required this.text,
    required this.createdAt,
  });

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      text: map['text'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
