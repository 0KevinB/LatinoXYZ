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

  @override
  void initState() {
    super.initState();
    _loadArtTypes();
  }

  Future<void> _loadArtTypes() async {
    final artTypes = await _artTypeService.getArtTypes();
    setState(() {
      _artTypes = artTypes;
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
          await _authService.requestArtistValidation(
            user.uid,
            artisticName: _artistNameController.text,
            birthDate: _birthDate!,
            nationality: _nationalityController.text,
            artistDescription: _descriptionController.text,
            artTypes: [_selectedArtType!],
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
              DropdownButtonFormField<ArtType>(
                value: _selectedArtType,
                items: _artTypes.map((ArtType artType) {
                  return DropdownMenuItem<ArtType>(
                    value: artType,
                    child: Text(artType.name),
                  );
                }).toList(),
                onChanged: (ArtType? newValue) {
                  setState(() {
                    _selectedArtType = newValue;
                  });
                },
                decoration: InputDecoration(labelText: 'Tipo de arte'),
                validator: (value) => value == null
                    ? 'Por favor selecciona un tipo de arte'
                    : null,
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
