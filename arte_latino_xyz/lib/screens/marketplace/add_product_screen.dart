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
    return Scaffold(
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoadingView() : _buildFormView(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Agregar Producto',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Container(
      decoration: _buildBackgroundDecoration(),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Container(
      decoration: _buildBackgroundDecoration(),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildFormSection(
                  'Información básica',
                  [
                    _buildTextField(
                      _nameController,
                      'Nombre del producto',
                      true,
                      icon: Icons.art_track,
                    ),
                    _buildTextField(
                      _priceController,
                      'Precio',
                      true,
                      keyboardType: TextInputType.number,
                      prefix: '\$',
                      icon: Icons.attach_money,
                    ),
                    _buildDropdownField(),
                  ],
                ),
                const SizedBox(height: 24),
                _buildFormSection(
                  'Detalles del producto',
                  [
                    _buildTextField(
                      _descriptionController,
                      'Descripción',
                      true,
                      maxLines: 3,
                      icon: Icons.description,
                    ),
                    _buildTextField(
                      _mediumController,
                      'Técnica o material',
                      true,
                      icon: Icons.brush,
                    ),
                    _buildTextField(
                      _sizeController,
                      'Tamaño',
                      true,
                      icon: Icons.straighten,
                    ),
                    _buildTextField(
                      _yearController,
                      'Año de creación',
                      true,
                      keyboardType: TextInputType.number,
                      icon: Icons.calendar_today,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildFormSection(
                  'Imagen del producto',
                  [_buildImageSection()],
                ),
                const SizedBox(height: 32),
                _buildSubmitButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBackgroundDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white, Colors.grey.shade50],
      ),
    );
  }

  Widget _buildFormSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    bool isRequired, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? prefix,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixText: prefix,
          prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black, width: 2),
          ),
          contentPadding: const EdgeInsets.all(16),
          labelStyle: TextStyle(color: Colors.grey.shade600),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 16),
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
          prefixIcon: const Icon(Icons.category, color: Colors.grey),
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black, width: 2),
          ),
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

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // _buildTextField(
        //   _imageUrlController,
        //   'URL de la imagen (opcional)',
        //   false,
        //   icon: Icons.link,
        // ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.photo_library),
          label: const Text('Seleccionar imagen de la galería'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: Colors.grey.shade100,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
        ),
        if (_imageFile != null)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Imagen seleccionada: ${_imageFile!.path.split('/').last}',
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF201658),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        elevation: 0,
      ),
      child: const Text(
        'Subir producto',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _category != null) {
      try {
        // Mostrar indicador de carga
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF201658)),
              ),
            );
          },
        );

        final newProduct = Product(
          id: const Uuid().v4(),
          name: _nameController.text,
          authorId: '',
          authorName: '',
          price: double.parse(_priceController.text),
          category: _category!,
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

        // Cerrar el indicador de carga
        Navigator.of(context).pop();

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Producto publicado exitosamente'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        Navigator.pop(context);
      } catch (e) {
        // Cerrar el indicador de carga
        Navigator.of(context).pop();

        // Mostrar mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Text('Error al publicar el producto: $e'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
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
