import 'package:arte_latino_xyz/models/post_model.dart';
import 'package:arte_latino_xyz/screens/auth/register_artist_screen.dart';
import 'package:arte_latino_xyz/screens/user/view_story_screen.dart';
import 'package:arte_latino_xyz/widgets/post_card.dart';
import 'package:arte_latino_xyz/widgets/story_circle.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:arte_latino_xyz/screens/user/artist/create_post_screen.dart';
import 'package:arte_latino_xyz/screens/user/artist/create_story_screen.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  void _showCreateOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.post_add),
                title: const Text('Crear Publicación'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreatePostScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_photo_alternate),
                title: const Text('Crear Historia'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateStoryScreen(),
                    ),
                  );
                },
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ArtistVerificationScreen()),
                  );
                },
                child: const Text(
                  'a',
                  style: TextStyle(
                    color: Color(0xFF201658),
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, authSnapshot) {
            if (authSnapshot.hasError) {
              return Center(
                child: Text('Error de autenticación: ${authSnapshot.error}'),
              );
            }

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  pinned: false,
                  snap: true,
                  title: const Text(
                    'Explorar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  centerTitle: true,
                  iconTheme: const IconThemeData(color: Colors.black),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.add_box_outlined),
                      onPressed: () => _showCreateOptions(context),
                    ),
                  ],
                ),
                // Stories Section
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Historias',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 90,
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('stories')
                                .where('expiresAt',
                                    isGreaterThan: Timestamp.now())
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Center(
                                  child: Text('Error: ${snapshot.error}'),
                                );
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return const Center(
                                  child: Text('No hay historias disponibles'),
                                );
                              }

                              return ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  final story = snapshot.data!.docs[index]
                                      .data() as Map<String, dynamic>;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: StoryCircle(
                                      imageUrl:
                                          story['mediaUrl'] as String? ?? '',
                                      username: story['username'] as String? ??
                                          'Usuario',
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ViewStoryScreen(
                                              userId: story['userId'] as String,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Posts Section
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: Text('Error: ${snapshot.error}'),
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SliverToBoxAdapter(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: Center(
                          child: Text('No hay publicaciones disponibles'),
                        ),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final post = snapshot.data!.docs[index].data()
                              as Map<String, dynamic>;
                          final dynamic likesData = post['likes'];
                          final List<String> likesList = likesData is int
                              ? []
                              : List<String>.from(likesData ?? []);

                          final List<Comment> commentsList =
                              (post['comments'] as List<dynamic>? ?? [])
                                  .map((comment) => Comment.fromMap(
                                      comment as Map<String, dynamic>))
                                  .toList();

                          return PostCard(
                            postId: snapshot.data!.docs[index].id,
                            username: post['username'] as String? ?? 'Usuario',
                            imageUrl: post['mediaUrl'] as String? ?? '',
                            caption: post['caption'] as String? ?? '',
                            likes: likesList,
                            userPhotoUrl: post['userPhotoUrl'] as String? ??
                                'https://via.placeholder.com/40',
                            comments: commentsList,
                          );
                        },
                        childCount: snapshot.data!.docs.length,
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
