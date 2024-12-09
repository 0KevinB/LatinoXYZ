// lib/models/user_model.dart
class UserModel {
  final String uid;
  final String email;
  final String? name;
  final String? phone;
  final String? photoUrl;
  final DateTime createdAt;
  final String authProvider; // 'email' o 'google'

  UserModel({
    required this.uid,
    required this.email,
    this.name,
    this.phone,
    this.photoUrl,
    required this.createdAt,
    required this.authProvider,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'authProvider': authProvider,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'],
      phone: map['phone'],
      photoUrl: map['photoUrl'],
      createdAt:
          DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      authProvider: map['authProvider'] ?? 'email',
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? phone,
    String? photoUrl,
    DateTime? createdAt,
    String? authProvider,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      authProvider: authProvider ?? this.authProvider,
    );
  }
}
