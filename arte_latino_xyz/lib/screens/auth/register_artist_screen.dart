import 'package:arte_latino_xyz/screens/user/explore_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/art_type_service.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';

class ArtistVerificationScreen extends StatefulWidget {
  const ArtistVerificationScreen({super.key});

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
  final Map<String, bool> _selectedCategories = {};
  final Map<String, List<String>> _selectedSubcategories = {};

  @override
  void initState() {
    super.initState();
    _loadArtTypes();
  }

  String _formatCategoryName(String name) {
    // Dictionary for special cases
    final specialCases = {
      'artesMusicales': 'Artes Musicales',
      'arteDigital': 'Arte Digital',
      'arteUrbano': 'Arte Urbano',
      'artesAplicadasYDiseño': 'Artes Aplicadas y Diseño',
      'artesLiterarias': 'Artes Literarias',
      'cineYVideoarte': 'Cine y Videoarte',
      'danza': 'Danza',
      'dibujo': 'Dibujo',
      'escultura': 'Escultura',
      'fotografia': 'Fotografía',
      'grabado': 'Grabado',
      'instalacionesArtisticas': 'Instalaciones Artísticas',
      'performance': 'Performance',
      'pintura': 'Pintura',
      'teatro': 'Teatro',
    };

    return specialCases[name] ?? name;
  }

  Widget _buildCategoriesSection() {
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Eres artista?',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF201658),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Si eres artista, puedes solicitar una verificación siguiendo los pasos a continuación.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 32),
          Text(
            'Selecciona tus categorías:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          ...(_artTypes.map((artType) => _buildCategoryCard(artType)).toList()),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(ArtType artType) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _selectedCategories[artType.name] == true
              ? Color(0xFF201658)
              : Colors.grey[300]!,
          width: _selectedCategories[artType.name] == true ? 2 : 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          unselectedWidgetColor: Colors.grey[400],
        ),
        child: ExpansionTile(
          title: Text(
            _formatCategoryName(
                artType.name), // Use the formatting function here
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: _selectedCategories[artType.name] == true
                  ? Color(0xFF201658)
                  : Colors.black87,
            ),
          ),
          leading: Checkbox(
            value: _selectedCategories[artType.name],
            activeColor: Color(0xFF201658),
            onChanged: (bool? selected) {
              setState(() {
                _selectedCategories[artType.name] = selected ?? false;
                if (!selected!) {
                  _selectedSubcategories[artType.name] = [];
                }
              });
            },
          ),
          children: [
            if (artType.techniques.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Subcategorías:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: artType.techniques.map((technique) {
                        final isSelected = _selectedSubcategories[artType.name]!
                            .contains(technique);
                        return FilterChip(
                          label: Text(technique),
                          selected: isSelected,
                          onSelected: _selectedCategories[artType.name] == true
                              ? (bool selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedSubcategories[artType.name]!
                                          .add(technique);
                                    } else {
                                      _selectedSubcategories[artType.name]!
                                          .remove(technique);
                                    }
                                  });
                                }
                              : null,
                          selectedColor: Color(0xFF201658).withOpacity(0.1),
                          checkmarkColor: Color(0xFF201658),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  InputDecoration _getCustomInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[600]),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF201658), width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Future<void> _loadArtTypes() async {
    final artTypes = await _artTypeService.getArtTypes();
    setState(() {
      _artTypes = artTypes;
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
              .where((entry) => entry.value)
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

  Widget _buildImagePicker(int index) {
    return GestureDetector(
      onTap: () => _pickImage(index),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: _selectedImages[index] != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(_selectedImages[index]!, fit: BoxFit.cover),
              )
            : Icon(Icons.add_photo_alternate,
                size: 40, color: Colors.grey[400]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verificación de Artista'),
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ExploreScreen()),
              );
            },
            child: Text(
              'Omitir por ahora',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          _buildCategoriesSection(),
          Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: _getCustomInputDecoration('Nombre completo'),
                    validator: (value) =>
                        value?.isEmpty == true ? 'Campo requerido' : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _artistNameController,
                    decoration: _getCustomInputDecoration('Nombre artístico'),
                    validator: (value) =>
                        value?.isEmpty == true ? 'Campo requerido' : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _nationalityController,
                    decoration: _getCustomInputDecoration('Nacionalidad'),
                    validator: (value) =>
                        value?.isEmpty == true ? 'Campo requerido' : null,
                  ),
                  SizedBox(height: 16),
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: _getCustomInputDecoration(''),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _birthDate == null
                                ? 'Seleccionar fecha de nacimiento'
                                : 'Fecha: ${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}',
                            style: TextStyle(fontSize: 16),
                          ),
                          Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Selecciona 3 imágenes de tus obras:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children:
                        List.generate(3, (index) => _buildImagePicker(index)),
                  ),
                  SizedBox(height: 24),
                  TextFormField(
                    controller: _descriptionController,
                    decoration:
                        _getCustomInputDecoration('Descripción artística')
                            .copyWith(alignLabelWithHint: true),
                    maxLines: 3,
                    validator: (value) =>
                        value?.isEmpty == true ? 'Campo requerido' : null,
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _requestVerification,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF201658),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text('Solicitar verificación',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              )),
                    ),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      )),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _artistNameController.dispose();
    _descriptionController.dispose();
    _nationalityController.dispose();
    super.dispose();
  }
}
