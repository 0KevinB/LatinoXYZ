import 'package:arte_latino_xyz/screens/admin/admin_validation_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panel de Administración'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildDashboardGrid(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement quick action
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Acción rápida presionada')),
          );
        },
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bienvenido, Admin',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Hoy es ${DateFormat('EEEE, d MMMM yyyy').format(DateTime.now())}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(16),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 0.75, // Ajuste para hacer las tarjetas más altas
      children: [
        _buildDashboardItem(
          context,
          'Validación de\nArtistas',
          Icons.verified_user,
          Colors.blue,
          Colors.lightBlue,
          '15',
          'Pendientes',
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ArtistValidationScreen()),
          ),
        ),
        _buildDashboardItem(
          context,
          'Usuarios\nActivos',
          Icons.people,
          Colors.green,
          Colors.lightGreen,
          '1,234',
          'Total',
          () {
            // TODO: Navigate to users screen
          },
        ),
        _buildDashboardItem(
          context,
          'Publicaciones',
          Icons.article,
          Colors.orange,
          Colors.amber,
          '789',
          'Últimos 30 días',
          () {
            // TODO: Navigate to posts screen
          },
        ),
        _buildDashboardItem(
          context,
          'Reportes',
          Icons.report_problem,
          Colors.red,
          Colors.redAccent,
          '5',
          'Sin resolver',
          () {
            // TODO: Navigate to reports screen
          },
        ),
      ],
    );
  }

  Widget _buildDashboardItem(
    BuildContext context,
    String title,
    IconData icon,
    Color startColor,
    Color endColor,
    String statistic,
    String statisticLabel,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [startColor, endColor],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 42, color: Colors.white), // Tamaño aumentado
              SizedBox(height: 8),
              Expanded(
                // Ajuste para evitar overflow en diferentes dispositivos
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Centra el contenido
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      statistic,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      statisticLabel,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
