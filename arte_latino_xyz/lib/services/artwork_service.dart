import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/artWorkModel.dart';

class ArtworkService {
  final CollectionReference _artworksCollection =
      FirebaseFirestore.instance.collection('artworks');

  Future<void> createArtwork(ArtworkModel artwork) async {
    try {
      await _artworksCollection.add(artwork.toMap());
      print('Artwork created successfully: ${artwork.toMap()}');
    } catch (e) {
      print('Error creating artwork: $e');
      throw e;
    }
  }

  Future<void> updateArtwork(ArtworkModel artwork) async {
    try {
      await _artworksCollection.doc(artwork.id).update(artwork.toMap());
      print('Artwork updated successfully: ${artwork.toMap()}');
    } catch (e) {
      print('Error updating artwork: $e');
      throw e;
    }
  }

  Stream<List<ArtworkModel>> getArtworksByArtist(String artistId) {
    return _artworksCollection
        .where('artistId', isEqualTo: artistId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ArtworkModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}
