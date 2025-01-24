// lib/models/user_model.dart

enum UserRole { user, artist, admin }

class UserModel {
  final String uid;
  final String email;
  final String? name;
  final String? phone;
  final String? photoUrl;
  final DateTime createdAt;
  final String authProvider;
  final UserRole role;

  // New fields for artist profile
  final String? artisticName;
  final DateTime? birthDate;
  final String? nationality;
  final String? artistDescription;

  UserModel({
    required this.uid,
    required this.email,
    this.name,
    this.phone,
    this.photoUrl,
    required this.createdAt,
    required this.authProvider,
    this.role = UserRole.user,
    this.artisticName,
    this.birthDate,
    this.nationality,
    this.artistDescription,
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
      'role': role.name,
      'artisticName': artisticName,
      'birthDate': birthDate?.toIso8601String(),
      'nationality': nationality,
      'artistDescription': artistDescription,
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
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.user,
      ),
      artisticName: map['artisticName'],
      birthDate:
          map['birthDate'] != null ? DateTime.parse(map['birthDate']) : null,
      nationality: map['nationality'],
      artistDescription: map['artistDescription'],
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
    UserRole? role,
    String? artisticName,
    DateTime? birthDate,
    String? nationality,
    String? artistDescription,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      authProvider: authProvider ?? this.authProvider,
      role: role ?? this.role,
      artisticName: artisticName ?? this.artisticName,
      birthDate: birthDate ?? this.birthDate,
      nationality: nationality ?? this.nationality,
      artistDescription: artistDescription ?? this.artistDescription,
    );
  }
}
