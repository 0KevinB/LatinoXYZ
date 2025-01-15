import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:arte_latino_xyz/models/post_model.dart';

class CommentsScreen extends StatefulWidget {
  final String postId;
  final List<Comment> comments;

  const CommentsScreen({
    super.key,
    required this.postId,
    required this.comments,
  });

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _addComment() async {
    if (_commentController.text.isNotEmpty) {
      final user = _auth.currentUser;
      if (user != null) {
        final newComment = Comment(
          userId: user.uid,
          username: user.displayName ?? 'Anonymous',
          text: _commentController.text,
          createdAt: DateTime.now(),
        );

        await _firestore.collection('posts').doc(widget.postId).update({
          'comments': FieldValue.arrayUnion([newComment.toMap()]),
        });

        _commentController.clear();
        setState(() {
          widget.comments.add(newComment);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.comments.length,
              itemBuilder: (context, index) {
                final comment = widget.comments[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(comment.username[0]),
                  ),
                  title: Text(comment.username),
                  subtitle: Text(comment.text),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _addComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
