import 'package:arte_latino_xyz/screens/user/view_story_screen.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class StoryCard extends StatelessWidget {
  final String userId;
  final String username;
  final String profileImageUrl;
  final bool hasStory;
  final BoxConstraints constraints;

  const StoryCard({
    super.key,
    required this.userId,
    required this.username,
    required this.profileImageUrl,
    required this.hasStory,
    required this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    final storySize = constraints.maxWidth * 0.15;

    return GestureDetector(
      onTap: hasStory
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewStoryScreen(userId: userId),
                ),
              );
            }
          : null,
      child: SizedBox(
        width: storySize,
        child: Column(
          children: [
            Container(
              width: storySize * 0.9,
              height: storySize * 0.9,
              decoration: BoxDecoration(
                gradient: hasStory
                    ? const LinearGradient(
                        colors: [Colors.purple, Colors.orange],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      )
                    : null,
                borderRadius: BorderRadius.circular(storySize * 0.45),
              ),
              padding: EdgeInsets.all(storySize * 0.03),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(storySize * 0.45),
                ),
                padding: EdgeInsets.all(storySize * 0.03),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(storySize * 0.45),
                  child: CachedNetworkImage(
                    imageUrl: profileImageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
              ),
            ),
            SizedBox(height: constraints.maxHeight * 0.01),
            Text(
              username,
              style: TextStyle(
                fontSize: constraints.maxWidth * 0.03,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
