import 'package:arte_latino_xyz/screens/admin/admin_validation_screen.dart';
import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panel de Administración'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildDashboardItem(
            context,
            'Validación de Artistas',
            Icons.verified_user,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ArtistValidationScreen()),
            ),
          ),
          // Add more dashboard items here as needed
        ],
      ),
    );
  }

  Widget _buildDashboardItem(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 40),
        title: Text(title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
