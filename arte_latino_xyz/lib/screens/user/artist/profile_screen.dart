import 'dart:convert';
import 'dart:typed_data';
import 'package:arte_latino_xyz/models/artWorkModel.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import '../../../services/auth_service.dart';
import '../../../services/artwork_service.dart';
import '../../../models/user_model.dart';

class ArtistProfilePage extends StatefulWidget {
  const ArtistProfilePage({Key? key}) : super(key: key);

  @override
  ArtistProfilePageState createState() => ArtistProfilePageState();
}

class ArtistProfilePageState extends State<ArtistProfilePage> {
  bool isFollowing = false;
  UserModel? artist;
  List<ArtworkModel> artworks = [];

  final AuthService _authService = AuthService();
  final ArtworkService _artworkService = ArtworkService();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _testImageUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      print('Image URL test: $url');
      print('Status code: ${response.statusCode}');
      if (response.statusCode != 200) {
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error testing image URL: $e');
    }
  }

  Future<void> _fetchUserData() async {
    User? currentUser = _authService.currentUser;
    print("currentUser: $currentUser");
    if (currentUser != null) {
      UserModel? fetchedUser = await _authService.getUserData(currentUser.uid);

      _artworkService
          .getArtworksByArtist(currentUser.uid)
          .listen((fetchedArtworks) {
        if (mounted) {
          setState(() {
            artist = fetchedUser;
            artworks = fetchedArtworks;
          });

          for (var artwork in fetchedArtworks) {
            _testImageUrl(artwork.photoUrl);
          }
        }
      });
    }
  }

  int _calculateAge(DateTime? birthDate) {
    if (birthDate == null) return 0;
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  void _showArtworkDialog({ArtworkModel? artwork}) {
    final nameController = TextEditingController(text: artwork?.name ?? '');
    final descriptionController =
        TextEditingController(text: artwork?.description ?? '');
    final locationController =
        TextEditingController(text: artwork?.location ?? '');
    final toolsController =
        TextEditingController(text: artwork?.tools.join(', ') ?? '');
    String? _base64Image;
    String? _imageUrl;

    Future<void> _getImage() async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _base64Image = base64Encode(bytes);
        });
      }
    }

    Future<String?> _uploadImage() async {
      if (_base64Image == null) return null;

      final storage = FirebaseStorage.instance;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final reference = storage.ref().child('artworks/$fileName');

      try {
        final Uint8List imageData = base64Decode(_base64Image!);
        await reference.putData(
            imageData, SettableMetadata(contentType: 'image/jpeg'));
        final downloadUrl = await reference.getDownloadURL();
        print('Image uploaded successfully. URL: $downloadUrl');
        return downloadUrl;
      } catch (e) {
        print('Error uploading image: $e');
        return null;
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(artwork == null ? 'Crear Obra' : 'Editar Obra'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Nombre de la Obra'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Descripción'),
                ),
                TextField(
                  controller: locationController,
                  decoration: InputDecoration(labelText: 'Ubicación'),
                ),
                TextField(
                  controller: toolsController,
                  decoration: InputDecoration(
                      labelText: 'Herramientas (separadas por coma)'),
                ),
                ElevatedButton(
                  child: Text('Seleccionar Imagen'),
                  onPressed: () async {
                    await _getImage();
                    setState(() {});
                  },
                ),
                if (_base64Image != null)
                  Image.memory(
                    base64Decode(_base64Image!),
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_base64Image != null) {
                  _imageUrl = await _uploadImage();
                }

                if (_imageUrl == null && artwork != null) {
                  _imageUrl = artwork.photoUrl;
                }

                final newArtwork = ArtworkModel(
                  id: artwork?.id,
                  name: nameController.text,
                  photoUrl: _imageUrl ?? '',
                  publicationDate: artwork?.publicationDate ?? DateTime.now(),
                  description: descriptionController.text,
                  tools: toolsController.text
                      .split(',')
                      .map((e) => e.trim())
                      .toList(),
                  location: locationController.text,
                  artistId: artist!.uid,
                );

                try {
                  if (artwork == null) {
                    await _artworkService.createArtwork(newArtwork);
                  } else {
                    await _artworkService.updateArtwork(newArtwork);
                  }
                  print('Artwork saved successfully: ${newArtwork.toMap()}');
                } catch (e) {
                  print('Error saving artwork: $e');
                }

                Navigator.of(context).pop();
              },
              child: Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (artist == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                          'https://images.pexels.com/photos/8033769/pexels-photo-8033769.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(30),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -50,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                        image: DecorationImage(
                          image: NetworkImage(artist?.photoUrl ??
                              'https://images.pexels.com/photos/18866495/pexels-photo-18866495/free-photo-of-mujer-jugando-musica-sonriente.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.withAlpha((0.9 * 255).toInt()),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 60),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        artist?.name ?? 'sin nombre',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.verified,
                              size: 16,
                              color: Colors.blue[600],
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Artista',
                              style: TextStyle(
                                color: Colors.blue[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isFollowing = !isFollowing;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isFollowing ? Colors.grey[200] : Colors.blue[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      isFollowing ? 'Siguiendo' : 'Seguir',
                      style: TextStyle(
                        color: isFollowing ? Colors.black87 : Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sobre mí',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        artist?.artistDescription ?? 'Sin descripción ƪ(˘⌣˘)ʃ',
                        style: TextStyle(
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nombre artístico:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(artist?.artisticName ?? 'no especificado'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'País:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(artist?.nationality ?? 'no especificado'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Edad:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('${_calculateAge(artist?.birthDate)} años'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Portafolio de obras',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.add_circle_outline),
                            onPressed: () => _showArtworkDialog(),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text('Ver todo'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: artworks.length,
                    itemBuilder: (context, index) {
                      final artwork = artworks[index];
                      print(
                          'Loading artwork ${artwork.id}: ${artwork.photoUrl}');

                      return GestureDetector(
                        onTap: () => _showArtworkDialog(artwork: artwork),
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: artwork.photoUrl.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: artwork.photoUrl,
                                        placeholder: (context, url) =>
                                            CircularProgressIndicator(),
                                        errorWidget: (context, url, error) {
                                          print('Error loading image: $error');
                                          return Container(
                                            color: Colors.grey[200],
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.error_outline,
                                                  color: Colors.red,
                                                  size: 30,
                                                ),
                                                SizedBox(height: 8),
                                                Text(
                                                  'Error al cargar',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        color: Colors.grey[200],
                                        child: Center(
                                          child: Icon(
                                            Icons.image,
                                            color: Colors.grey[400],
                                            size: 30,
                                          ),
                                        ),
                                      ),
                              ),
                              Container(
                                padding: EdgeInsets.all(8),
                                color: Colors.white,
                                child: Text(
                                  artwork.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
