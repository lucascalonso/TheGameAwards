import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Painel Administrativo"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () =>
                Provider.of<AuthProvider>(context, listen: false).logout(),
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(16),
        children: [
          _buildMenuCard(context, "Gerenciar Jogos", Icons.gamepad, () {
            /* Navegar para GameList */
          }),
          _buildMenuCard(context, "Categorias", Icons.category, () {
            /* Navegar para CategoryList */
          }),
          _buildMenuCard(context, "Busca/Filtros", Icons.search, () {
            /* Navegar para SearchScreen */
          }),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(icon, size: 50), Text(title)],
        ),
      ),
    );
  }
}
