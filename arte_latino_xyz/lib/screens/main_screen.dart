import 'package:arte_latino_xyz/screens/user/likes_screen.dart';
import 'package:arte_latino_xyz/screens/marketplace/marketplace_screen.dart';
import 'package:arte_latino_xyz/screens/user/artist/profile_screen.dart';
import 'package:arte_latino_xyz/screens/user/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:arte_latino_xyz/widgets/custom_botton_navigation.dart';
import 'package:arte_latino_xyz/screens/user/explore_screen.dart';
// Import other screen widgets as needed

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ExploreScreen(),
    LikesPage(),
    const MarketplacePage(),
    const SearchPage(),
    const ArtistProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF201658),
      unselectedItemColor: const Color(0xFF201658).withOpacity(0.5),
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: const TextStyle(
        fontSize: 12, // Tamaño del texto cuando está seleccionado
        fontWeight:
            FontWeight.w600, // Un poco más grueso cuando está seleccionado
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 11, // Tamaño del texto cuando no está seleccionado
        fontWeight: FontWeight.normal,
      ),
      iconSize: 24, // Tamaño de los iconos
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Favoritos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.store),
          label: 'Marketplace',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Buscar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }
}
