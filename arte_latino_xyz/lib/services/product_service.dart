import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/product_model.dart';
import 'auth_service.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final AuthService _authService = AuthService();

  CollectionReference get _products => _firestore.collection('products');

  Future<String> uploadImage(File image) async {
    final user = _authService.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final ref = _storage
        .ref()
        .child('product_images/${DateTime.now().toIso8601String()}.jpg');
    final uploadTask = ref.putFile(image);
    final snapshot = await uploadTask.whenComplete(() {});
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> addProduct(Product product, {File? imageFile}) async {
    try {
      final user = _authService.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final userData = await _authService.getUserData(user.uid);
      if (userData == null) throw Exception('User data not found');

      String imageUrl = product.imageUrl;
      if (imageFile != null) {
        imageUrl = await uploadImage(imageFile);
      }

      final newProduct = Product(
        id: product.id,
        name: product.name,
        authorId: user.uid,
        authorName: userData.name ?? 'Unknown Artist',
        price: product.price,
        category: product.category,
        colors: product.colors,
        description: product.description,
        imageUrl: imageUrl,
        medium: product.medium,
        size: product.size,
        yearCreated: product.yearCreated,
        tags: product.tags,
        createdAt: DateTime.now(),
      );

      await _products.doc(newProduct.id).set(newProduct.toMap());
    } catch (e) {
      print('Error adding product: $e');
      rethrow;
    }
  }

  Future<List<Product>> getProducts() async {
    try {
      final snapshot = await _products.get();
      return snapshot.docs
          .map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting products: $e');
      rethrow;
    }
  }

  Future<Product?> getProduct(String id) async {
    try {
      final doc = await _products.doc(id).get();
      if (doc.exists) {
        return Product.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting product: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _products.doc(product.id).update(product.toMap());
    } catch (e) {
      print('Error updating product: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _products.doc(id).delete();
    } catch (e) {
      print('Error deleting product: $e');
      rethrow;
    }
  }

  Stream<List<Product>> streamProducts() {
    return _products.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }
}
