class ArtworkModel {
  final String? id;
  final String name;
  String photoUrl;
  final DateTime publicationDate;
  final String description;
  final List<String> tools;
  final String location;
  final String artistId;

  ArtworkModel({
    this.id,
    required this.name,
    this.photoUrl = '',
    required this.publicationDate,
    required this.description,
    required this.tools,
    required this.location,
    required this.artistId,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'photoUrl': photoUrl,
      'publicationDate': publicationDate.toIso8601String(),
      'description': description,
      'tools': tools,
      'location': location,
      'artistId': artistId,
    };
  }

  factory ArtworkModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ArtworkModel(
      id: documentId,
      name: map['name'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      publicationDate: DateTime.parse(map['publicationDate']),
      description: map['description'] ?? '',
      tools: List<String>.from(map['tools'] ?? []),
      location: map['location'] ?? '',
      artistId: map['artistId'] ?? '',
    );
  }
}
