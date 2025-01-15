import 'package:flutter/material.dart';

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
    // Get screen width to calculate icon size
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth * 0.06;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey[300]!,
            width: 0.5,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          _buildNavItem(Icons.home_outlined, 'Home', iconSize),
          _buildNavItem(Icons.favorite_border, 'Favorites', iconSize),
          _buildNavItem(Icons.shopping_cart_outlined, 'Cart', iconSize),
          _buildNavItem(Icons.search, 'Search', iconSize),
          _buildNavItem(Icons.person_outline, 'Profile', iconSize),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
      IconData icon, String label, double size) {
    return BottomNavigationBarItem(
      icon: Icon(icon, size: size),
      label: label,
    );
  }
}
