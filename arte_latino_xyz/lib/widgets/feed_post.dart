import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FeedPost extends StatefulWidget {
  final String username;
  final String timeAgo;
  final String imageUrl;
  final String likes;
  final String caption;
  final BoxConstraints constraints;
  final bool isVideo;

  const FeedPost({
    super.key,
    required this.username,
    required this.timeAgo,
    required this.imageUrl,
    required this.likes,
    required this.caption,
    required this.constraints,
    required this.isVideo,
  });

  @override
  _FeedPostState createState() => _FeedPostState();
}

class _FeedPostState extends State<FeedPost> {
  late VideoPlayerController _controller;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.isVideo) {
      _controller = VideoPlayerController.network(widget.imageUrl)
        ..initialize().then((_) {
          setState(() {
            _isVideoInitialized = true;
          });
        });
    }
  }

  @override
  void dispose() {
    if (widget.isVideo) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = widget.constraints.maxWidth * 0.04;
    final verticalPadding = widget.constraints.maxHeight * 0.02;
    final avatarSize = widget.constraints.maxWidth * 0.08;

    return Container(
      margin: EdgeInsets.only(bottom: verticalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding * 0.5,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: avatarSize * 0.5,
                      backgroundColor: Colors.grey[300],
                      child: Icon(Icons.person, size: avatarSize * 0.6),
                    ),
                    SizedBox(width: horizontalPadding * 0.5),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.username,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: widget.constraints.maxWidth * 0.035,
                          ),
                        ),
                        Text(
                          widget.timeAgo,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: widget.constraints.maxWidth * 0.03,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    Icons.more_horiz,
                    size: widget.constraints.maxWidth * 0.06,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          // Media
          AspectRatio(
            aspectRatio: 1,
            child: widget.isVideo
                ? _isVideoInitialized
                    ? VideoPlayer(_controller)
                    : const Center(child: CircularProgressIndicator())
                : Image.network(
                    widget.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  ),
          ),
          // Actions
          Padding(
            padding: EdgeInsets.all(horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildActionButton(Icons.favorite_border),
                    SizedBox(width: horizontalPadding),
                    _buildActionButton(Icons.chat_bubble_outline),
                    SizedBox(width: horizontalPadding),
                    _buildActionButton(Icons.share),
                    if (widget.isVideo)
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: Icon(
                              _controller.value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              size: widget.constraints.maxWidth * 0.06,
                            ),
                            onPressed: () {
                              setState(() {
                                _controller.value.isPlaying
                                    ? _controller.pause()
                                    : _controller.play();
                              });
                            },
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: verticalPadding),
                Text(
                  'Le gusta a ${widget.likes}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: widget.constraints.maxWidth * 0.035,
                  ),
                ),
                SizedBox(height: verticalPadding * 0.5),
                Text(
                  widget.caption,
                  style: TextStyle(
                    fontSize: widget.constraints.maxWidth * 0.035,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon) {
    return IconButton(
      icon: Icon(
        icon,
        size: widget.constraints.maxWidth * 0.06,
      ),
      onPressed: () {},
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }
}
