import 'package:arte_latino_xyz/models/artWorkModel.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/artwork_service.dart';
import '../models/user_model.dart';

class ArtistProfilePage extends StatefulWidget {
  const ArtistProfilePage({super.key});

  @override
  ArtistProfilePageState createState() => ArtistProfilePageState();
}

class ArtistProfilePageState extends State<ArtistProfilePage> {
  bool isFollowing = false;
  UserModel? artist;
  List<ArtworkModel> artworks = [];

  final AuthService _authService = AuthService();
  final ArtworkService _artworkService = ArtworkService();

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

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
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
        }
      });
    }
  }

  void _showArtworkDialog({ArtworkModel? artwork}) {
    final nameController = TextEditingController(text: artwork?.name ?? '');
    final descriptionController =
        TextEditingController(text: artwork?.description ?? '');
    final locationController =
        TextEditingController(text: artwork?.location ?? '');
    final toolsController =
        TextEditingController(text: artwork?.tools.join(', ') ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                onPressed: () {
                  // Implementar selección de imagen
                },
              )
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
              final newArtwork = ArtworkModel(
                id: artwork?.id,
                name: nameController.text,
                photoUrl: '', // Pendiente implementación de imagen
                publicationDate: artwork?.publicationDate ?? DateTime.now(),
                description: descriptionController.text,
                tools: toolsController.text
                    .split(',')
                    .map((e) => e.trim())
                    .toList(),
                location: locationController.text,
                artistId: artist!.uid,
              );

              if (artwork == null) {
                await _artworkService.createArtwork(newArtwork);
              } else {
                await _artworkService.updateArtwork(newArtwork);
              }

              Navigator.of(context).pop();
            },
            child: Text('Guardar'),
          ),
        ],
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
            // Header Stack with cover image and profile photo
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Cover Image with curved bottom
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
                // Profile Image
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
                // Back Button
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

            SizedBox(height: 60), // Space for profile picture overflow

            // Profile Info
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Name and Badge
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

                  // Follow Button
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

                  // About Section
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

                  // Artist Info
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

                  // Portfolio Section
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

                  // Artwork Grid
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
                      return GestureDetector(
                        onTap: () => _showArtworkDialog(artwork: artwork),
                        child: Card(
                          child: Column(
                            children: [
                              Image.network(artwork.photoUrl,
                                  height: 100, fit: BoxFit.cover),
                              Text(artwork.name),
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
