import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/admin_service.dart';

class ArtistValidationScreen extends StatefulWidget {
  const ArtistValidationScreen({Key? key}) : super(key: key);

  @override
  _ArtistValidationScreenState createState() => _ArtistValidationScreenState();
}

class _ArtistValidationScreenState extends State<ArtistValidationScreen> {
  final AdminService _adminService = AdminService();
  List<UserModel> _pendingArtists = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingArtists();
  }

  Future<void> _loadPendingArtists() async {
    setState(() => _isLoading = true);
    try {
      final artists = await _adminService.getPendingArtistValidations();
      setState(() {
        _pendingArtists = artists;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading pending artists: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _validateArtist(String uid, bool isApproved) async {
    try {
      await _adminService.validateArtist(uid, isApproved);
      await _loadPendingArtists();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(isApproved ? 'Artista aprobado' : 'Artista rechazado')),
      );
    } catch (e) {
      print('Error validating artist: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al procesar la solicitud')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Validación de Artistas'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _pendingArtists.isEmpty
              ? Center(child: Text('No hay artistas pendientes de validación'))
              : ListView.builder(
                  itemCount: _pendingArtists.length,
                  itemBuilder: (context, index) {
                    final artist = _pendingArtists[index];
                    return Card(
                      margin: EdgeInsets.all(8),
                      child: ExpansionTile(
                        title: Text(artist.name ?? 'Nombre no disponible'),
                        subtitle: Text(artist.artisticName ??
                            'Nombre artístico no disponible'),
                        children: [
                          ListTile(
                            title: Text('Nacionalidad'),
                            subtitle:
                                Text(artist.nationality ?? 'No disponible'),
                          ),
                          ListTile(
                            title: Text('Fecha de nacimiento'),
                            subtitle: Text(artist.birthDate?.toString() ??
                                'No disponible'),
                          ),
                          ListTile(
                            title: Text('Descripción'),
                            subtitle: Text(
                                artist.artistDescription ?? 'No disponible'),
                          ),
                          ListTile(
                            title: Text('Tipos de arte'),
                            subtitle: Text(
                                artist.artTypes.map((e) => e.name).join(', ')),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () =>
                                    _validateArtist(artist.uid, true),
                                child: Text('Aprobar'),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green),
                              ),
                              ElevatedButton(
                                onPressed: () =>
                                    _validateArtist(artist.uid, false),
                                child: Text('Rechazar'),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
