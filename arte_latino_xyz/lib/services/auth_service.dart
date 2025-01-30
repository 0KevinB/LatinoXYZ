import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _users => _firestore.collection('users');

  Future<void> _createUserInFirestore(UserModel user) async {
    await _users.doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> getUserData(String uid) async {
    final doc = await _users.doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final user = UserModel(
          uid: userCredential.user!.uid,
          email: email,
          name: name,
          phone: phone,
          createdAt: DateTime.now(),
          authProvider: 'email',
        );

        await _createUserInFirestore(user);
        await userCredential.user!.updateDisplayName(name);
      }

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        final user = UserModel(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email!,
          name: userCredential.user!.displayName,
          photoUrl: userCredential.user!.photoURL,
          createdAt: DateTime.now(),
          authProvider: 'google',
        );

        await _createUserInFirestore(user);
      }

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    await _users.doc(uid).update(data);
  }

  Future<void> requestArtistValidation(
    String uid, {
    required String artisticName,
    required DateTime birthDate,
    required String nationality,
    required String artistDescription,
    required List<ArtType> artTypes,
  }) async {
    final userData = {
      'artisticName': artisticName,
      'birthDate': birthDate.toIso8601String(),
      'nationality': nationality,
      'artistDescription': artistDescription,
      'artTypes': artTypes.map((artType) => artType.toMap()).toList(),
      'artistValidationStatus': ArtistValidationStatus.pending.name,
    };

    await updateUserData(uid, userData);
  }

  Future<void> validateArtist(String uid, bool isApproved) async {
    final status = isApproved
        ? ArtistValidationStatus.approved
        : ArtistValidationStatus.rejected;
    final role = isApproved ? UserRole.artist : UserRole.user;

    await updateUserData(uid, {
      'artistValidationStatus': status.name,
      'role': role.name,
    });
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
