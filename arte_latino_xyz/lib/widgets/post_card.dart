import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';

class PostCard extends StatefulWidget {
  final String postId;
  final String username;
  final String imageUrl;
  final String caption;
  final List<String> likes;
  final String userPhotoUrl;
  final List<Comment> comments;

  const PostCard({
    super.key,
    required this.postId,
    required this.username,
    required this.imageUrl,
    required this.caption,
    required this.likes,
    required this.userPhotoUrl,
    required this.comments,
  });

  @override
  PostCardState createState() => PostCardState();
}

class PostCardState extends State<PostCard> {
  bool _isLiked = false;
  bool _showAllComments = false;
  final int _initialCommentCount = 2;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkIfLiked();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _checkIfLiked() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        _isLiked = widget.likes.contains(currentUser.uid);
      });
    }
  }

  void _toggleLike() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final postRef =
          FirebaseFirestore.instance.collection('posts').doc(widget.postId);

      if (_isLiked) {
        postRef.update({
          'likes': FieldValue.arrayRemove([currentUser.uid])
        });
      } else {
        postRef.update({
          'likes': FieldValue.arrayUnion([currentUser.uid])
        });
      }

      setState(() {
        _isLiked = !_isLiked;
      });
    }
  }

  void _sharePost() {
    Share.share('Check out this post: ${widget.caption}');
  }

  void _addComment() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && _commentController.text.isNotEmpty) {
      final postRef =
          FirebaseFirestore.instance.collection('posts').doc(widget.postId);

      final newComment = Comment(
        userId: currentUser.uid,
        username: currentUser.displayName ?? 'Usuario',
        text: _commentController.text,
        createdAt: DateTime.now(),
      );

      postRef.update({
        'comments': FieldValue.arrayUnion([newComment.toMap()])
      });

      _commentController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(widget.userPhotoUrl),
            ),
            title: Text(widget.username),
          ),
          Image.network(
            widget.imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        color: _isLiked ? Colors.red : null,
                      ),
                      onPressed: _toggleLike,
                    ),
                    IconButton(
                      icon: const Icon(Icons.comment_outlined),
                      onPressed: () {
                        // Scroll to comment input field
                        Scrollable.ensureVisible(context,
                            duration: const Duration(milliseconds: 300));
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.share_outlined),
                      onPressed: _sharePost,
                    ),
                    const Spacer(),
                    Text('${widget.likes.length} likes'),
                  ],
                ),
                Text(
                  widget.caption,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildCommentSection(),
                const SizedBox(height: 8),
                _buildCommentInput(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentSection() {
    final displayedComments = _showAllComments
        ? widget.comments
        : widget.comments.take(_initialCommentCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...displayedComments.map((comment) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    TextSpan(
                      text: '${comment.username} ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: comment.text),
                  ],
                ),
              ),
            )),
        if (widget.comments.length > _initialCommentCount)
          TextButton(
            onPressed: () {
              setState(() {
                _showAllComments = !_showAllComments;
              });
            },
            child: Text(_showAllComments ? 'Ocultar' : 'Ver más comentarios'),
          ),
      ],
    );
  }

  Widget _buildCommentInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              hintText: 'Añade un comentario...',
              border: InputBorder.none,
            ),
          ),
        ),
        TextButton(
          onPressed: _addComment,
          child: const Text('Publicar'),
        ),
      ],
    );
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
