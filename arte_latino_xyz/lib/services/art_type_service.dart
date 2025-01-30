import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class ArtTypeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<ArtType>> getArtTypes() async {
    try {
      final snapshot =
          await _firestore.collection('arts_types').doc('tipos').get();
      final data = snapshot.data() as Map<String, dynamic>;

      return data.entries.map((entry) {
        return ArtType(
          name: entry.key,
          techniques: List<String>.from(entry.value),
        );
      }).toList();
    } catch (e) {
      print('Error fetching art types: $e');
      return [];
    }
  }
}
