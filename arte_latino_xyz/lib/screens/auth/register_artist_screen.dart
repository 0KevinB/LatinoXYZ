import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/art_type_service.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';

class ArtistVerificationScreen extends StatefulWidget {
  const ArtistVerificationScreen({Key? key}) : super(key: key);

  @override
  _ArtistVerificationScreenState createState() =>
      _ArtistVerificationScreenState();
}

class _ArtistVerificationScreenState extends State<ArtistVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _artistNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _nationalityController = TextEditingController();
  DateTime? _birthDate;
  ArtType? _selectedArtType;
  List<ArtType> _artTypes = [];
  final List<File?> _selectedImages = List.filled(3, null);
  final _picker = ImagePicker();
  final _artTypeService = ArtTypeService();
  final _authService = AuthService();
  bool _isLoading = false;
  Map<String, bool> _selectedCategories = {};
  Map<String, List<String>> _selectedSubcategories = {};

  @override
  void initState() {
    super.initState();
    _loadArtTypes();
  }

  Future<void> _loadArtTypes() async {
    final artTypes = await _artTypeService.getArtTypes();
    setState(() {
      _artTypes = artTypes;
      // Inicializar el estado de selección
      for (var artType in artTypes) {
        _selectedCategories[artType.name] = false;
        _selectedSubcategories[artType.name] = [];
      }
    });
  }

  Future<void> _pickImage(int index) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImages[index] = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al seleccionar la imagen'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  Future<void> _requestVerification() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedImages.where((image) => image != null).length < 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, selecciona las 3 imágenes requeridas'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        final user = _authService.currentUser;
        if (user != null) {
          List<ArtType> selectedArtTypes = _selectedCategories.entries
              .where((entry) => entry.value) // Filtra los seleccionados
              .map((entry) => ArtType(
                    name: entry.key,
                    techniques: _selectedSubcategories[entry.key] ?? [],
                  ))
              .toList();

          await _authService.requestArtistValidation(
            user.uid,
            artisticName: _artistNameController.text,
            birthDate: _birthDate!,
            nationality: _nationalityController.text,
            artistDescription: _descriptionController.text,
            artTypes: selectedArtTypes,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Solicitud de verificación enviada')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Verificación de Artista')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nombre completo'),
                validator: (value) =>
                    value?.isEmpty == true ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _artistNameController,
                decoration: InputDecoration(labelText: 'Nombre artístico'),
                validator: (value) =>
                    value?.isEmpty == true ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _nationalityController,
                decoration: InputDecoration(labelText: 'Nacionalidad'),
                validator: (value) =>
                    value?.isEmpty == true ? 'Campo requerido' : null,
              ),
              ListTile(
                title: Text(_birthDate == null
                    ? 'Seleccionar fecha de nacimiento'
                    : 'Fecha de nacimiento: ${_birthDate!.toLocal().toString().split(' ')[0]}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              SizedBox(height: 16),
              Text('Selecciona tu tipo de arte y subcategorías:'),
              Column(
                children: _artTypes.map((artType) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CheckboxListTile(
                        title: Text(artType.name,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        value: _selectedCategories[artType.name],
                        onChanged: (bool? selected) {
                          setState(() {
                            _selectedCategories[artType.name] =
                                selected ?? false;
                            // Si se desmarca, limpiar las subcategorías seleccionadas
                            if (!selected!) {
                              _selectedSubcategories[artType.name] = [];
                            }
                          });
                        },
                      ),
                      if (_selectedCategories[artType
                          .name]!) // Mostrar subcategorías si la categoría está marcada
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Column(
                            children: artType.techniques.map((subtype) {
                              return CheckboxListTile(
                                title: Text(subtype),
                                value: _selectedSubcategories[artType.name]!
                                    .contains(subtype),
                                onChanged: (bool? selected) {
                                  setState(() {
                                    if (selected!) {
                                      _selectedSubcategories[artType.name]!
                                          .add(subtype);
                                    } else {
                                      _selectedSubcategories[artType.name]!
                                          .remove(subtype);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              Text('Selecciona 3 imágenes de tus obras:'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(3, (index) => _buildImagePicker(index)),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Descripción artística'),
                maxLines: 3,
                validator: (value) =>
                    value?.isEmpty == true ? 'Campo requerido' : null,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _requestVerification,
                child: _isLoading
                    ? CircularProgressIndicator()
                    : Text('Solicitar verificación'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker(int index) {
    return GestureDetector(
      onTap: () => _pickImage(index),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: _selectedImages[index] != null
            ? Image.file(_selectedImages[index]!, fit: BoxFit.cover)
            : Icon(Icons.add_photo_alternate, size: 40),
      ),
    );
  }
}
