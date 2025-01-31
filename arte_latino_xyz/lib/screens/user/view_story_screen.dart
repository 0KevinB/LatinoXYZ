import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';

class ViewStoryScreen extends StatefulWidget {
  final String userId;

  const ViewStoryScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _ViewStoryScreenState createState() => _ViewStoryScreenState();
}

class _ViewStoryScreenState extends State<ViewStoryScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  List<DocumentSnapshot> _stories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadStories();
  }

  Future<void> _loadStories() async {
    final storiesSnapshot = await FirebaseFirestore.instance
        .collection('stories')
        .where('userId', isEqualTo: widget.userId)
        .where('expiresAt', isGreaterThan: Timestamp.now())
        .orderBy('expiresAt', descending: false)
        .get();

    setState(() {
      _stories = storiesSnapshot.docs;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildStoryContent(String mediaUrl) {
    if (mediaUrl.contains('.mp4')) {
      return _VideoPlayerWidget(videoUrl: mediaUrl);
    } else {
      return CachedNetworkImage(
        imageUrl: mediaUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) =>
            const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_stories.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No hay historias disponibles')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) {
          final screenWidth = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < screenWidth / 2) {
            if (_currentPage > 0) {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          } else {
            if (_currentPage < _stories.length - 1) {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            } else {
              Navigator.of(context).pop();
            }
          }
        },
        child: PageView.builder(
          controller: _pageController,
          itemCount: _stories.length,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          itemBuilder: (context, index) {
            final story = _stories[index].data() as Map<String, dynamic>;
            return Stack(
              fit: StackFit.expand,
              children: [
                _buildStoryContent(story['mediaUrl'] as String),
                Positioned(
                  top: 40,
                  left: 10,
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage:
                            NetworkImage(story['profileImageUrl'] as String),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        story['username'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const _VideoPlayerWidget({Key? key, required this.videoUrl})
      : super(key: key);

  @override
  __VideoPlayerWidgetState createState() => __VideoPlayerWidgetState();
}

class __VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : const Center(child: CircularProgressIndicator());
  }
}
