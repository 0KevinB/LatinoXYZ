import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:arte_latino_xyz/services/product_service.dart';
import 'package:arte_latino_xyz/services/art_type_service.dart';
import 'package:arte_latino_xyz/models/product_model.dart';
import 'package:uuid/uuid.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productService = ProductService();
  final _artTypeService = ArtTypeService();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _mediumController = TextEditingController();
  final _sizeController = TextEditingController();
  final _yearController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String? _category;
  final List<String> _colors = [];
  final List<String> _tags = [];
  File? _imageFile;
  List<String> _categoryOptions = [];
  bool _isLoading = true;

  // Mapa para convertir los nombres de categorías
  final Map<String, String> categoryNames = {
    'arteDigital': 'Arte Digital',
    'arteUrbano': 'Arte Urbano',
    'artesAplicadasYDiseño': 'Artes Aplicadas y Diseño',
    'artesLiterarias': 'Artes Literarias',
    'artesMusicales': 'Artes Musicales',
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

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final artTypes = await _artTypeService.getArtTypes();
      setState(() {
        _categoryOptions = artTypes.map((type) => type.name).toList();
        _category = _categoryOptions.isNotEmpty ? _categoryOptions[0] : null;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading categories: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _imageUrlController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Agregar Producto'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Producto'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(_nameController, 'Nombre de la obra', true),
                _buildTextField(_priceController, 'Precio', true,
                    keyboardType: TextInputType.number),
                _buildDropdownField(),
                _buildTextField(_descriptionController, 'Descripción', true,
                    maxLines: 3),
                _buildTextField(_mediumController, 'Técnica o material', true),
                _buildTextField(_sizeController, 'Tamaño', true),
                _buildTextField(_yearController, 'Año de creación', true,
                    keyboardType: TextInputType.number),
                _buildTextField(
                    _imageUrlController, 'URL de la imagen (opcional)', false),
                _buildImagePickerButton(),
                if (_imageFile != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Imagen seleccionada: ${_imageFile!.path}'),
                  ),
                SizedBox(height: 16),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, bool isRequired,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'Por favor ingrese $label';
          }
          if (keyboardType == TextInputType.number && isRequired) {
            if (double.tryParse(value ?? '') == null) {
              return 'Por favor ingrese un número válido';
            }
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: _category,
        decoration: InputDecoration(
          labelText: 'Categoría',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: _categoryOptions.map((String category) {
          return DropdownMenuItem(
            value: category,
            child: Text(categoryNames[category] ?? category),
          );
        }).toList(),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor seleccione una categoría';
          }
          return null;
        },
        onChanged: (String? newValue) {
          setState(() {
            _category = newValue;
          });
        },
      ),
    );
  }

  Widget _buildImagePickerButton() {
    return ElevatedButton(
      onPressed: _pickImage,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.grey[200],
      ),
      child: Text('Seleccionar imagen de la galería'),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(vertical: 16),
      ),
      child: Text('Agregar Producto'),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _category != null) {
      try {
        final newProduct = Product(
          id: Uuid().v4(),
          name: _nameController.text,
          authorId: '',
          authorName: '',
          price: double.parse(_priceController.text),
          category: _category!, // Guardamos la categoría original
          colors: _colors,
          description: _descriptionController.text,
          imageUrl: _imageUrlController.text,
          medium: _mediumController.text,
          size: _sizeController.text,
          yearCreated: int.parse(_yearController.text),
          tags: _tags,
          createdAt: DateTime.now(),
        );

        await _productService.addProduct(newProduct, imageFile: _imageFile);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Producto agregado exitosamente')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al agregar el producto: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _mediumController.dispose();
    _sizeController.dispose();
    _yearController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
}
