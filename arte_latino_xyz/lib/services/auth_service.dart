// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Referencia a la colección de usuarios
  CollectionReference get _users => _firestore.collection('users');

  // Crear usuario en Firestore
  Future<void> _createUserInFirestore(UserModel user) async {
    await _users.doc(user.uid).set(user.toMap());
  }

  // Obtener usuario de Firestore
  Future<UserModel?> getUserData(String uid) async {
    final doc = await _users.doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Registro con email y contraseña
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

        // Actualizar el displayName en Firebase Auth
        await userCredential.user!.updateDisplayName(name);
      }

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Inicio de sesión con Google
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

      // Si es un nuevo usuario, guardar en Firestore
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

  // Actualizar datos del usuario
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    await _users.doc(uid).update(data);
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  // Obtener usuario actual
  User? get currentUser => _auth.currentUser;

  // Stream del estado de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
