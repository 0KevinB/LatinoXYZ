import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<UserModel>> getPendingArtistValidations() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('artistValidationStatus',
              isEqualTo: ArtistValidationStatus.pending.name)
          .get();

      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
    } catch (e) {
      print('Error fetching pending artist validations: $e');
      return [];
    }
  }

  Future<void> validateArtist(String uid, bool isApproved) async {
    try {
      final status = isApproved
          ? ArtistValidationStatus.approved
          : ArtistValidationStatus.rejected;
      final role = isApproved ? UserRole.artist : UserRole.user;

      await _firestore.collection('users').doc(uid).update({
        'artistValidationStatus': status.name,
        'role': role.name,
      });
    } catch (e) {
      print('Error validating artist: $e');
      throw e;
    }
  }
}
