import 'package:arte_latino_xyz/models/post_model.dart';
import 'package:arte_latino_xyz/screens/admin/admin_dashboard.dart';
import 'package:arte_latino_xyz/screens/auth/login_screen.dart';
import 'package:arte_latino_xyz/screens/user/view_story_screen.dart';
import 'package:arte_latino_xyz/widgets/post_card.dart';
import 'package:arte_latino_xyz/widgets/story_circle.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:arte_latino_xyz/screens/user/artist/create_post_screen.dart';
import 'package:arte_latino_xyz/screens/user/artist/create_story_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  // Cache para posts
  List<QueryDocumentSnapshot>? _cachedPosts;
  // Cache para stories
  List<QueryDocumentSnapshot>? _cachedStories;
  // Controlador para el scroll
  final ScrollController _scrollController = ScrollController();
  // Límite inicial de posts a cargar
  final int _postsLimit = 10;
  bool _isLoadingMore = false;

  // Streams
  late Stream<QuerySnapshot> _postsStream;
  late Stream<QuerySnapshot> _storiesStream;

  @override
  void initState() {
    super.initState();
    _initializeStreams();
    _setupScrollListener();
  }

  void _initializeStreams() {
    _postsStream = FirebaseFirestore.instance
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .limit(_postsLimit)
        .snapshots();

    _storiesStream = FirebaseFirestore.instance
        .collection('stories')
        .where('expiresAt', isGreaterThan: Timestamp.now())
        .snapshots();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent * 0.8) {
        _loadMorePosts();
      }
    });
  }

  Future<void> _loadMorePosts() async {
    if (!_isLoadingMore && _cachedPosts != null) {
      setState(() => _isLoadingMore = true);

      final lastPost = _cachedPosts!.last;
      final nextPosts = await FirebaseFirestore.instance
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .startAfterDocument(lastPost)
          .limit(_postsLimit)
          .get();

      if (nextPosts.docs.isNotEmpty) {
        setState(() {
          _cachedPosts!.addAll(nextPosts.docs);
          _isLoadingMore = false;
        });
      } else {
        setState(() => _isLoadingMore = false);
      }
    }
  }

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
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Cerrar Sesión'),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  }
                },
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminDashboardScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Administrar',
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

  Widget _buildStoriesSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: _storiesStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            _cachedStories == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final stories = snapshot.data?.docs ?? _cachedStories ?? [];
        if (snapshot.hasData) {
          _cachedStories = stories;
        }

        if (stories.isEmpty) {
          return const Center(child: Text('No hay historias disponibles'));
        }

        return SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: stories.length,
            itemBuilder: (context, index) {
              final story = stories[index].data() as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: StoryCircle(
                  imageUrl: story['mediaUrl'] as String? ?? '',
                  username: story['username'] as String? ?? 'Usuario',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewStoryScreen(
                          userId: story['userId'] as String,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPostsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _postsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            _cachedPosts == null) {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final posts = snapshot.data?.docs ?? _cachedPosts ?? [];
        if (snapshot.hasData) {
          _cachedPosts = posts;
        }

        if (posts.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(child: Text('No hay publicaciones disponibles')),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index >= posts.length) {
                return _isLoadingMore
                    ? const Center(child: CircularProgressIndicator())
                    : const SizedBox();
              }

              final post = posts[index].data() as Map<String, dynamic>;
              final dynamic likesData = post['likes'];
              final List<String> likesList =
                  likesData is int ? [] : List<String>.from(likesData ?? []);

              final List<Comment> commentsList =
                  (post['comments'] as List<dynamic>? ?? [])
                      .map((comment) =>
                          Comment.fromMap(comment as Map<String, dynamic>))
                      .toList();

              return PostCard(
                postId: posts[index].id,
                username: post['username'] as String? ?? 'Usuario',
                mediaUrl: post['mediaUrl'] as String? ?? '',
                caption: post['caption'] as String? ?? '',
                likes: likesList,
                userPhotoUrl: post['userPhotoUrl'] as String? ??
                    'https://via.placeholder.com/40',
                comments: commentsList,
                isVideo: post['isVideo'] as bool? ?? false,
              );
            },
            childCount: posts.length + 1,
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
              controller: _scrollController,
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
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
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
                        _buildStoriesSection(),
                      ],
                    ),
                  ),
                ),
                _buildPostsList(),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
