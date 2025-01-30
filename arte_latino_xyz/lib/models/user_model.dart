import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { user, artist, admin }

enum ArtistValidationStatus { pending, approved, rejected }

class ArtType {
  final String name;
  final List<String> techniques;

  ArtType({required this.name, required this.techniques});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'techniques': techniques,
    };
  }

  factory ArtType.fromMap(Map<String, dynamic> map) {
    return ArtType(
      name: map['name'] ?? '',
      techniques: List<String>.from(map['techniques'] ?? []),
    );
  }
}

class UserModel {
  final String uid;
  final String email;
  final String? name;
  final String? phone;
  final String? photoUrl;
  final DateTime createdAt;
  final String authProvider;
  final UserRole role;

  // Artist profile fields
  final String? artisticName;
  final DateTime? birthDate;
  final String? nationality;
  final String? artistDescription;
  final ArtistValidationStatus artistValidationStatus;
  final List<ArtType> artTypes;

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
    this.artistValidationStatus = ArtistValidationStatus.pending,
    this.artTypes = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'authProvider': authProvider,
      'role': role.name,
      'artisticName': artisticName,
      'birthDate': birthDate != null ? Timestamp.fromDate(birthDate!) : null,
      'nationality': nationality,
      'artistDescription': artistDescription,
      'artistValidationStatus': artistValidationStatus.name,
      'artTypes': artTypes.map((artType) => artType.toMap()).toList(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'],
      phone: map['phone'],
      photoUrl: map['photoUrl'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      authProvider: map['authProvider'] ?? 'email',
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.user,
      ),
      artisticName: map['artisticName'],
      birthDate: map['birthDate'] != null
          ? (map['birthDate'] as Timestamp).toDate()
          : null,
      nationality: map['nationality'],
      artistDescription: map['artistDescription'],
      artistValidationStatus: ArtistValidationStatus.values.firstWhere(
        (e) => e.name == map['artistValidationStatus'],
        orElse: () => ArtistValidationStatus.pending,
      ),
      artTypes: (map['artTypes'] as List<dynamic>?)
              ?.map((artType) => ArtType.fromMap(artType))
              .toList() ??
          [],
    );
  }
}
