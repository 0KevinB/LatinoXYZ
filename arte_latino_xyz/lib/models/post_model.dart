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
  final bool isVideo; // Added isVideo field

  PostModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.text,
    required this.createdAt,
    required this.comments,
    required this.likes,
    this.mediaUrl,
    this.isVideo = false, // Default value is false
  });

  factory PostModel.fromMap(Map<String, dynamic> map, String id) {
    // Handle null or missing timestamp
    DateTime parseTimestamp(dynamic timestamp) {
      if (timestamp == null) return DateTime.now();
      if (timestamp is Timestamp) return timestamp.toDate();
      if (timestamp is DateTime) return timestamp;
      return DateTime.now();
    }

    return PostModel(
      id: id,
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      text: map['caption'] ?? '',
      createdAt: parseTimestamp(map['createdAt']),
      comments: (map['comments'] as List<dynamic>? ?? [])
          .map((comment) => Comment.fromMap(comment as Map<String, dynamic>))
          .toList(),
      likes: List<String>.from(map['likes'] ?? []),
      mediaUrl: map['mediaUrl'],
      isVideo: map['isVideo'] ?? false, // Parse isVideo from map
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
      'isVideo': isVideo, // Include isVideo in map
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
    // Handle null or missing timestamp for comments
    DateTime parseTimestamp(dynamic timestamp) {
      if (timestamp == null) return DateTime.now();
      if (timestamp is Timestamp) return timestamp.toDate();
      if (timestamp is DateTime) return timestamp;
      return DateTime.now();
    }

    return Comment(
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      text: map['text'] ?? '',
      createdAt: parseTimestamp(map['createdAt']),
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
