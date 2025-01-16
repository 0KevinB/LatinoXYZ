import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:story_view/story_view.dart';

class ViewStoryScreen extends StatefulWidget {
  final String userId;

  const ViewStoryScreen({super.key, required this.userId});

  @override
  ViewStoryScreenState createState() => ViewStoryScreenState();
}

class ViewStoryScreenState extends State<ViewStoryScreen> {
  final StoryController controller = StoryController();
  List<StoryItem> storyItems = [];

  @override
  void initState() {
    super.initState();
    _loadStories();
  }

  Future<void> _loadStories() async {
    final now = DateTime.now();
    final stories = await FirebaseFirestore.instance
        .collection('stories')
        .where('userId', isEqualTo: widget.userId)
        .where('expiresAt', isGreaterThan: now)
        .orderBy('expiresAt', descending: false)
        .get();

    setState(() {
      storyItems = stories.docs.map((doc) {
        final data = doc.data();
        if (data['isVideo'] == true) {
          return StoryItem.pageVideo(
            data['mediaUrl'],
            controller: controller,
          );
        } else {
          return StoryItem.pageImage(
            url: data['mediaUrl'],
            controller: controller,
          );
        }
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    MaterialApp(
      debugShowCheckedModeBanner: false,
    );
    return Scaffold(
      body: storyItems.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : StoryView(
              storyItems: storyItems,
              controller: controller,
              onComplete: () {
                Navigator.pop(context);
              },
              onVerticalSwipeComplete: (direction) {
                if (direction == Direction.down) {
                  Navigator.pop(context);
                }
              },
            ),
    );
  }
}
