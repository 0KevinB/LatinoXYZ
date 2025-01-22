import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String productId;
  final String productName;
  final String imageUrl;
  final double price;
  final String size;
  final String category;
  final String authorName;
  int quantity;

  CartItem({
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.price,
    required this.size,
    required this.category,
    required this.authorName,
    this.quantity = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'imageUrl': imageUrl,
      'price': price,
      'size': size,
      'category': category,
      'authorName': authorName,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      productId: map['productId'],
      productName: map['productName'],
      imageUrl: map['imageUrl'],
      price: map['price'].toDouble(),
      size: map['size'],
      category: map['category'],
      authorName: map['authorName'],
      quantity: map['quantity'],
    );
  }
}

class Cart {
  final String userId;
  final List<CartItem> items;
  final DateTime updatedAt;

  Cart({
    required this.userId,
    required this.items,
    required this.updatedAt,
  });

  double get subtotal =>
      items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  double get shipping => items.isEmpty ? 0 : 9.90;
  double get total => subtotal + shipping;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory Cart.fromMap(String userId, Map<String, dynamic> map) {
    return Cart(
      userId: userId,
      items: (map['items'] as List<dynamic>)
          .map((item) => CartItem.fromMap(item))
          .toList(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  factory Cart.empty(String userId) {
    return Cart(
      userId: userId,
      items: [],
      updatedAt: DateTime.now(),
    );
  }
}
