import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../user/search_screen.dart';
import 'game_list.dart';
import 'category_list.dart';
import '../../widgets/base_layout.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return BaseLayout(
      appBar: AppBar(
        title: const Text("Painel Admin"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => auth.logout(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Bem-vindo, ${auth.user?.name}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.gold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            _AdminMenuButton(
              icon: Icons.videogame_asset,
              label: "Gerenciar Jogos",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GameListScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            _AdminMenuButton(
              icon: Icons.category,
              label: "Gerenciar Categorias",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CategoryListScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            _AdminMenuButton(
              icon: Icons.search,
              label: "Buscar e Filtros",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminMenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AdminMenuButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(20),
        backgroundColor: AppTheme.surfaceColor,
      ),
      onPressed: onTap,
      child: Row(
        children: [
          Icon(icon, size: 30, color: AppTheme.gold),
          const SizedBox(width: 20),
          Text(label, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
