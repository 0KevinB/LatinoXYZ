import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:story_view/story_view.dart';

class ViewStoryScreen extends StatefulWidget {
  final String userId;
  final String username;
  final String profileImageUrl;

  const ViewStoryScreen({
    Key? key,
    required this.userId,
    required this.username,
    required this.profileImageUrl,
  }) : super(key: key);

  @override
  ViewStoryScreenState createState() => ViewStoryScreenState();
}

class ViewStoryScreenState extends State<ViewStoryScreen> {
  final StoryController controller = StoryController();
  List<StoryItem> storyItems = [];
  late String username;
  late String profileImageUrl;

  @override
  void initState() {
    super.initState();
    username = widget.username;
    profileImageUrl = widget.profileImageUrl;
    _loadStories();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _loadStories() async {
    try {
      final now = DateTime.now();
      final QuerySnapshot stories = await FirebaseFirestore.instance
          .collection('stories')
          .where('userId', isEqualTo: widget.userId)
          .where('expiresAt', isGreaterThan: Timestamp.fromDate(now))
          .orderBy('expiresAt')
          .get();

      if (!mounted) return;

      final List<StoryItem> items = [];
      for (var doc in stories.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final mediaUrl = data['mediaUrl'] as String;

        try {
          if (data['isVideo'] == true) {
            items.add(StoryItem.pageVideo(
              mediaUrl,
              controller: controller,
            ));
          } else {
            items.add(StoryItem.pageImage(
              url: mediaUrl,
              controller: controller,
            ));
          }
        } catch (e) {
          debugPrint('Error loading media: $e');
          // Skip this item if there's an error
          continue;
        }
      }

      if (!mounted) return;
      setState(() {
        storyItems = items;
      });
    } catch (e) {
      debugPrint('Error loading stories: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading stories: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: storyItems.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                StoryView(
                  storyItems: storyItems,
                  controller: controller,
                  onComplete: () => Navigator.pop(context),
                  onVerticalSwipeComplete: (direction) {
                    if (direction == Direction.down) {
                      Navigator.pop(context);
                    }
                  },
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: profileImageUrl.isNotEmpty
                              ? NetworkImage(profileImageUrl)
                              : null,
                          radius: 20,
                          child: profileImageUrl.isEmpty
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          username,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
