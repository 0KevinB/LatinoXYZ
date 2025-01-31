import 'package:arte_latino_xyz/models/post_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

class PostCard extends StatefulWidget {
  final String postId;
  final String username;
  final String mediaUrl;
  final String caption;
  final List<String> likes;
  final String userPhotoUrl;
  final List<Comment> comments;
  final bool isVideo;

  const PostCard({
    Key? key,
    required this.postId,
    required this.username,
    required this.mediaUrl,
    required this.caption,
    required this.likes,
    required this.userPhotoUrl,
    required this.comments,
    required this.isVideo,
  }) : super(key: key);

  @override
  PostCardState createState() => PostCardState();
}

class PostCardState extends State<PostCard> {
  bool _isLiked = false;
  bool _showAllComments = false;
  final int _initialCommentCount = 2;
  final TextEditingController _commentController = TextEditingController();
  late VideoPlayerController _videoPlayerController;
  bool _isVideoInitialized = false;
  double? _aspectRatio;

  @override
  void initState() {
    super.initState();
    _checkIfLiked();
    if (widget.isVideo) {
      _initializeVideoPlayer();
    } else {
      _loadImage();
    }
  }

  void _initializeVideoPlayer() {
    _videoPlayerController = VideoPlayerController.network(widget.mediaUrl)
      ..initialize().then((_) {
        setState(() {
          _isVideoInitialized = true;
          _aspectRatio = _videoPlayerController.value.aspectRatio;
        });
      });
  }

  void _loadImage() {
    final image = Image.network(widget.mediaUrl);
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        setState(() {
          _aspectRatio = info.image.width / info.image.height;
        });
      }),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    if (widget.isVideo) {
      _videoPlayerController.dispose();
    }
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
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(widget.userPhotoUrl),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.username,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  iconSize: 20,
                  onPressed: () {},
                ),
              ],
            ),
          ),
          // Media content
          AspectRatio(
            aspectRatio: 1, // Mantener el contenedor cuadrado
            child: Container(
              color: Colors.black, // Fondo negro para las franjas
              child: Center(
                child: _aspectRatio != null
                    ? AspectRatio(
                        aspectRatio: _aspectRatio!,
                        child: widget.isVideo
                            ? _buildVideoPlayer()
                            : Image.network(
                                widget.mediaUrl,
                                fit: BoxFit.contain,
                              ),
                      )
                    : const CircularProgressIndicator(),
              ),
            ),
          ),
          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? Colors.red : null,
                    size: 24,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: _toggleLike,
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(
                    Icons.mode_comment_outlined,
                    size: 24,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {},
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(
                    Icons.send_outlined,
                    size: 24,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: _sharePost,
                ),
              ],
            ),
          ),
          // Likes
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '${widget.likes.length} Me gusta',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          // Caption
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 14),
                children: [
                  TextSpan(
                    text: '${widget.username} ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: widget.caption),
                ],
              ),
            ),
          ),
          // Comments
          if (widget.comments.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.comments.length > 2 && !_showAllComments)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _showAllComments = true;
                        });
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Ver los ${widget.comments.length} comentarios',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ..._buildComments(),
                ],
              ),
            ),
          // Comment Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Añade un comentario...',
                      hintStyle: TextStyle(fontSize: 14),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _addComment,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Publicar',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildComments() {
    final commentsToShow = _showAllComments
        ? widget.comments
        : widget.comments.take(_initialCommentCount).toList();

    return commentsToShow
        .map(
          (comment) => Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 14),
                children: [
                  TextSpan(
                    text: '${comment.username} ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: comment.text),
                ],
              ),
            ),
          ),
        )
        .toList();
  }

  Widget _buildVideoPlayer() {
    if (!_isVideoInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        VideoPlayer(_videoPlayerController),
        IconButton(
          icon: Icon(
            _videoPlayerController.value.isPlaying
                ? Icons.pause
                : Icons.play_arrow,
            size: 50,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              _videoPlayerController.value.isPlaying
                  ? _videoPlayerController.pause()
                  : _videoPlayerController.play();
            });
          },
        ),
      ],
    );
  }
}
