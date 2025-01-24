import 'package:arte_latino_xyz/screens/likes_screen.dart';
import 'package:arte_latino_xyz/screens/marketplace_screen.dart';
import 'package:arte_latino_xyz/screens/profile_screen.dart';
import 'package:arte_latino_xyz/screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:arte_latino_xyz/widgets/custom_botton_navigation.dart';
import 'package:arte_latino_xyz/screens/explore_screen.dart';
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
    LikesPage(), // Replace with actual Favorites screen
    const MarketplacePage(), // Replace with actual Cart screen
    const SearchPage(), // Replace with actual Search screen
    const ArtistProfilePage(), // Replace with actual Profile screen
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    MaterialApp(
      debugShowCheckedModeBanner: false,
    );
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
