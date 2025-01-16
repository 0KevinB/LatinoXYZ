import 'package:flutter/material.dart';

import 'package:arte_latino_xyz/models/post_model.dart';

class CommentSection extends StatelessWidget {
  final String postId;
  final List<Comment> comments;

  const CommentSection({
    super.key,
    required this.postId,
    required this.comments,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Comments',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: comments.length > 2 ? 2 : comments.length,
          itemBuilder: (context, index) {
            final comment = comments[index];
            return ListTile(
              leading: const CircleAvatar(
                backgroundImage: NetworkImage('https://via.placeholder.com/40'),
              ),
              title: Text(comment.username),
              subtitle: Text(comment.text),
            );
          },
        ),
        if (comments.length > 2)
          TextButton(
            onPressed: () {
              // Todo Implement view all comments functionality
            },
            child: Text('View all ${comments.length} comments'),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              const Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
                    border: InputBorder.none,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Todo implement post comment functionality
                },
                child: const Text('Post'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
