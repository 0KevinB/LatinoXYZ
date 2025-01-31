import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardItem {
  final String title;
  final IconData icon;
  final Color startColor;
  final Color endColor;
  final String statistic;
  final String statisticLabel;
  final VoidCallback? onTap;

  const DashboardItem({
    required this.title,
    required this.icon,
    required this.startColor,
    required this.endColor,
    required this.statistic,
    required this.statisticLabel,
    this.onTap,
  });
}

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: const AdminDashboardView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Acción rápida presionada')),
          );
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardHeader(),
          DashboardGrid(),
        ],
      ),
    );
  }
}

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bienvenido, Admin',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
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
}

class DashboardGrid extends StatelessWidget {
  const DashboardGrid({super.key});

  List<DashboardItem> get _dashboardItems => [
        DashboardItem(
          title: 'Validación de Artistas',
          icon: Icons.verified_user,
          startColor: Colors.blue,
          endColor: Colors.lightBlue,
          statistic: '1',
          statisticLabel: 'Pendiente',
          onTap: () {
            // TODO: Implementar navegación a validación de artistas
          },
        ),
        DashboardItem(
          title: 'Usuarios Activos',
          icon: Icons.people,
          startColor: Colors.green,
          endColor: Colors.lightGreen,
          statistic: '1,432',
          statisticLabel: 'Total',
          onTap: () {
            // TODO: Implementar navegación a usuarios
          },
        ),
        DashboardItem(
          title: 'Publicaciones',
          icon: Icons.article,
          startColor: Colors.orange,
          endColor: Colors.amber,
          statistic: '12',
          statisticLabel: 'Últimos 30 días',
          onTap: () {
            // TODO: Implementar navegación a publicaciones
          },
        ),
        DashboardItem(
          title: 'Reportes',
          icon: Icons.report_problem,
          startColor: Colors.red,
          endColor: Colors.redAccent,
          statistic: '2',
          statisticLabel: 'Sin resolver',
          onTap: () {
            // TODO: Implementar navegación a reportes
          },
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: constraints.maxWidth > 600 ? 1.5 : 1.2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _dashboardItems.length,
            itemBuilder: (context, index) {
              return DashboardCard(item: _dashboardItems[index]);
            },
          );
        },
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final DashboardItem item;

  const DashboardCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [item.startColor, item.endColor],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(item.icon, size: 48, color: Colors.white),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.statistic,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    item.statisticLabel,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
