import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';

class LikesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<PostModel>> getLikedPostsStream(String userId) {
    try {
      // First, try to get posts without ordering to avoid index issues
      return _firestore
          .collection('posts')
          .where('likes', arrayContains: userId)
          .snapshots()
          .map((snapshot) {
        final posts = snapshot.docs.map((doc) {
          return PostModel.fromMap(doc.data(), doc.id);
        }).toList();

        // Sort posts in memory if index is not available
        posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return posts;
      });
    } catch (e) {
      print('Error setting up likes stream: $e');
      return Stream.value([]);
    }
  }

  Future<void> toggleLike(String postId, String userId) async {
    try {
      final postRef = _firestore.collection('posts').doc(postId);

      return _firestore.runTransaction((transaction) async {
        final postDoc = await transaction.get(postRef);

        if (!postDoc.exists) {
          throw Exception('Post does not exist!');
        }

        List<String> likes = List<String>.from(postDoc.data()?['likes'] ?? []);

        if (likes.contains(userId)) {
          likes.remove(userId);
        } else {
          likes.add(userId);
        }

        transaction.update(postRef, {'likes': likes});
      });
    } catch (e) {
      print('Error toggling like: $e');
      rethrow;
    }
  }
}
