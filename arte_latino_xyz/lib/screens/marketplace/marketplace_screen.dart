import 'package:arte_latino_xyz/models/product_model.dart';
import 'package:arte_latino_xyz/models/user_model.dart';
import 'package:arte_latino_xyz/screens/marketplace/add_product_screen.dart';
import 'package:arte_latino_xyz/screens/marketplace/product_screen.dart';
import 'package:arte_latino_xyz/services/art_type_service.dart';
import 'package:arte_latino_xyz/services/product_service.dart';
import 'package:flutter/material.dart';

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});

  @override
  _MarketplacePageState createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  final ProductService _productService = ProductService();
  final ArtTypeService _artTypeService = ArtTypeService();
  String _selectedCategory = 'Todas';
  List<ArtType> _artTypes = [];
  bool _isLoading = true;

  final Color primaryColor = Color(0xFF201658);
  final Color cardColor = Color.fromARGB(255, 255, 254, 252);

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
    _loadArtTypes();
  }

  Future<void> _loadArtTypes() async {
    try {
      final types = await _artTypeService.getArtTypes();
      setState(() {
        _artTypes = types;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading art types: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Marketplace - ${categoryNames[_selectedCategory] ?? _selectedCategory}',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_bag_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar producto...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
              ),
            ),
          ),
          if (_isLoading)
            Center(child: CircularProgressIndicator())
          else
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Wrap(
                spacing: 4.0,
                runSpacing: 4.0,
                children: _buildFilterChips(),
              ),
            ),
          SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<List<Product>>(
              stream: _productService.streamProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No hay productos disponibles.'));
                }
                List<Product> products = snapshot.data!;
                if (_selectedCategory != 'Todas') {
                  products = products
                      .where((product) => product.category == _selectedCategory)
                      .toList();
                }
                return GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  padding: EdgeInsets.all(16),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: products
                      .map((product) => _buildProductCard(context, product))
                      .toList(),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProductScreen()),
          );
        },
        backgroundColor: primaryColor,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  List<Widget> _buildFilterChips() {
    List<Widget> chips = [];
    List<String> categories = ['Todas', ..._artTypes.map((e) => e.name)];

    int maxVisible = 3;
    bool showMore = categories.length > maxVisible;

    for (int i = 0; i < (showMore ? maxVisible : categories.length); i++) {
      chips.add(_buildFilterChip(categories[i]));
    }

    if (showMore) {
      chips.add(_buildFilterChip('Ver más'));
    }

    return chips;
  }

  Widget _buildFilterChip(String category) {
    final isSelected = _selectedCategory == category;
    return ChoiceChip(
      label: Text(
        category == 'Todas' || category == 'Ver más'
            ? category
            : categoryNames[category] ?? category,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          fontSize: 12,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (category == 'Ver más') {
            _showMoreCategories();
          } else {
            _selectedCategory = selected ? category : 'Todas';
          }
        });
      },
      backgroundColor: Colors.transparent,
      selectedColor: primaryColor,
      pressElevation: 0,
      shadowColor: Colors.transparent,
      showCheckmark: true,
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide.none,
      ),
      labelPadding: EdgeInsets.symmetric(horizontal: 8),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  void _showMoreCategories() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              children: _artTypes
                  .skip(3)
                  .map((type) => ListTile(
                        title: Text(categoryNames[type.name] ?? type.name),
                        onTap: () {
                          setState(() {
                            _selectedCategory = type.name;
                          });
                          Navigator.pop(context);
                        },
                      ))
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Card(
        elevation: 2,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  image: DecorationImage(
                    image: NetworkImage(product.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                product.name,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('\$${product.price}',
                  style: TextStyle(color: Colors.grey)),
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
