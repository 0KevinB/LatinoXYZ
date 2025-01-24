// lib/services/artwork_service.dart
import 'package:arte_latino_xyz/models/artWorkModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ArtworkService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _artworks => _firestore.collection('artworks');

  // Crear nueva obra
  Future<String> createArtwork(ArtworkModel artwork) async {
    final docRef = await _artworks.add(artwork.toMap());
    return docRef.id;
  }

  // Obtener obras de un artista
  Stream<List<ArtworkModel>> getArtworksByArtist(String artistId) {
    return _artworks
        .where('artistId', isEqualTo: artistId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ArtworkModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ))
            .toList());
  }

  // Actualizar obra
  Future<void> updateArtwork(ArtworkModel artwork) async {
    if (artwork.id == null) return;
    await _artworks.doc(artwork.id).update(artwork.toMap());
  }

  // Eliminar obra
  Future<void> deleteArtwork(String artworkId) async {
    await _artworks.doc(artworkId).delete();
  }
}
