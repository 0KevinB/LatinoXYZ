import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ArtistVerificationScreen extends StatefulWidget {
  const ArtistVerificationScreen({super.key});
  @override
  State<ArtistVerificationScreen> createState() =>
      _ArtistVerificationScreenState();
}

class _ArtistVerificationScreenState extends State<ArtistVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _artistNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedArtType;
  final List<String> _artTypes = [
    'Pintura',
    'Escultura',
    'Fotografía',
    'Arte digital',
    'Otro'
  ];

  List<File?> _selectedImages = List.filled(3, null);
  final _picker = ImagePicker();

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

  void _requestVerification() {
    if (_formKey.currentState!.validate()) {
      // Verificar que se hayan seleccionado las 3 imágenes
      if (_selectedImages.where((image) => image != null).length < 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, selecciona las 3 imágenes requeridas'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // TODO: Implement verification request logic
      Navigator.pop(context);
    }
  }

  void _skipVerification() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _skipVerification,
            child: const Text(
              'Omitir por ahora',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '¿Eres artista?',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Si eres artista, puedes solicitar una verificación siguiendo los pasos a continuación.\nNo te preocupes, podrás solicitar la verificación cuando gustes.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Nombres y Apellidos',
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) =>
                      value?.isEmpty == true ? 'Este campo es requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _artistNameController,
                  decoration: InputDecoration(
                    hintText: 'Nombre artístico (opcional)',
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedArtType,
                  decoration: InputDecoration(
                    hintText: 'Tipo de arte',
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: _artTypes
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedArtType = value);
                  },
                  validator: (value) => value == null
                      ? 'Por favor selecciona un tipo de arte'
                      : null,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Por favor, adjunta 3 obras o arte de tu propiedad',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(
                    3,
                    (index) => GestureDetector(
                      onTap: () => _pickImage(index),
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue.shade200),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _selectedImages[index] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _selectedImages[index]!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(
                                Icons.add_photo_alternate_outlined,
                                color: Colors.blue,
                                size: 32,
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Por último, damos una breve descripción de ti',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Ingresa aquí tu descripción...',
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) =>
                      value?.isEmpty == true ? 'Este campo es requerido' : null,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _requestVerification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1a237e),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Solicitar verificación',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
